Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 36E2F6B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 10:59:10 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o17-v6so23755430iob.12
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 07:59:10 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o4-v6sor3892451itf.43.2018.04.26.07.59.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 26 Apr 2018 07:59:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180426145056.220325-2-edumazet@google.com>
References: <20180426145056.220325-1-edumazet@google.com> <20180426145056.220325-2-edumazet@google.com>
From: Soheil Hassas Yeganeh <soheil@google.com>
Date: Thu, 26 Apr 2018 10:58:27 -0400
Message-ID: <CACSApvYeDP0uLh6iJ=HUCBk-WVWUWh2ZyvaZSJq0XfGNJXV=Pg@mail.gmail.com>
Subject: Re: [PATCH v3 net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ka-Cheong Poon <ka-cheong.poon@oracle.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Thu, Apr 26, 2018 at 10:50 AM, Eric Dumazet <edumazet@google.com> wrote:
> When adding tcp mmap() implementation, I forgot that socket lock
> had to be taken before current->mm->mmap_sem. syzbot eventually caught
> the bug.
>
> Since we can not lock the socket in tcp mmap() handler we have to
> split the operation in two phases.
>
> 1) mmap() on a tcp socket simply reserves VMA space, and nothing else.
>   This operation does not involve any TCP locking.
>
> 2) getsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) implements
>  the transfert of pages from skbs to one VMA.
>   This operation only uses down_read(&current->mm->mmap_sem) after
>   holding TCP lock, thus solving the lockdep issue.
>
> This new implementation was suggested by Andy Lutomirski with great details.
>
> Benefits are :
>
> - Better scalability, in case multiple threads reuse VMAS
>    (without mmap()/munmap() calls) since mmap_sem wont be write locked.
>
> - Better error recovery.
>    The previous mmap() model had to provide the expected size of the
>    mapping. If for some reason one part could not be mapped (partial MSS),
>    the whole operation had to be aborted.
>    With the tcp_zerocopy_receive struct, kernel can report how
>    many bytes were successfuly mapped, and how many bytes should
>    be read to skip the problematic sequence.
>
> - No more memory allocation to hold an array of page pointers.
>   16 MB mappings needed 32 KB for this array, potentially using vmalloc() :/
>
> - skbs are freed while mmap_sem has been released
>
> Following patch makes the change in tcp_mmap tool to demonstrate
> one possible use of mmap() and setsockopt(... TCP_ZEROCOPY_RECEIVE ...)
>
> Note that memcg might require additional changes.
>
> Fixes: 93ab6cc69162 ("tcp: implement mmap() for zero copy receive")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: syzbot <syzkaller@googlegroups.com>
> Suggested-by: Andy Lutomirski <luto@kernel.org>
> Cc: linux-mm@kvack.org
> Cc: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

getsockopt() is indeed a better choice. Thanks!

> ---
>  include/uapi/linux/tcp.h |   8 ++
>  net/ipv4/tcp.c           | 192 ++++++++++++++++++++-------------------
>  2 files changed, 109 insertions(+), 91 deletions(-)
>
> diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
> index 379b08700a542d49bbce9b4b49b17879d00b69bb..e9e8373b34b9ddc735329341b91f455bf5c0b17c 100644
> --- a/include/uapi/linux/tcp.h
> +++ b/include/uapi/linux/tcp.h
> @@ -122,6 +122,7 @@ enum {
>  #define TCP_MD5SIG_EXT         32      /* TCP MD5 Signature with extensions */
>  #define TCP_FASTOPEN_KEY       33      /* Set the key for Fast Open (cookie) */
>  #define TCP_FASTOPEN_NO_COOKIE 34      /* Enable TFO without a TFO cookie */
> +#define TCP_ZEROCOPY_RECEIVE   35
>
>  struct tcp_repair_opt {
>         __u32   opt_code;
> @@ -276,4 +277,11 @@ struct tcp_diag_md5sig {
>         __u8    tcpm_key[TCP_MD5SIG_MAXKEYLEN];
>  };
>
> +/* setsockopt(fd, IPPROTO_TCP, TCP_ZEROCOPY_RECEIVE, ...) */
> +
> +struct tcp_zerocopy_receive {
> +       __u64 address;          /* in: address of mapping */
> +       __u32 length;           /* in/out: number of bytes to map/mapped */
> +       __u32 recv_skip_hint;   /* out: amount of bytes to skip */
> +};
>  #endif /* _UAPI_LINUX_TCP_H */
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index dfd090ea54ad47112fc23c61180b5bf8edd2c736..c10c4a41ad39d6f8ae472882b243c2b70c915546 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -1726,118 +1726,111 @@ int tcp_set_rcvlowat(struct sock *sk, int val)
>  }
>  EXPORT_SYMBOL(tcp_set_rcvlowat);
>
> -/* When user wants to mmap X pages, we first need to perform the mapping
> - * before freeing any skbs in receive queue, otherwise user would be unable
> - * to fallback to standard recvmsg(). This happens if some data in the
> - * requested block is not exactly fitting in a page.
> - *
> - * We only support order-0 pages for the moment.
> - * mmap() on TCP is very strict, there is no point
> - * trying to accommodate with pathological layouts.
> - */
> +static const struct vm_operations_struct tcp_vm_ops = {
> +};
> +
>  int tcp_mmap(struct file *file, struct socket *sock,
>              struct vm_area_struct *vma)
>  {
> -       unsigned long size = vma->vm_end - vma->vm_start;
> -       unsigned int nr_pages = size >> PAGE_SHIFT;
> -       struct page **pages_array = NULL;
> -       u32 seq, len, offset, nr = 0;
> -       struct sock *sk = sock->sk;
> -       const skb_frag_t *frags;
> +       if (vma->vm_flags & (VM_WRITE | VM_EXEC))
> +               return -EPERM;
> +       vma->vm_flags &= ~(VM_MAYWRITE | VM_MAYEXEC);
> +
> +       /* Instruct vm_insert_page() to not down_read(mmap_sem) */
> +       vma->vm_flags |= VM_MIXEDMAP;
> +
> +       vma->vm_ops = &tcp_vm_ops;
> +       return 0;
> +}
> +EXPORT_SYMBOL(tcp_mmap);
> +
> +static int tcp_zerocopy_receive(struct sock *sk,
> +                               struct tcp_zerocopy_receive *zc)
> +{
> +       unsigned long address = (unsigned long)zc->address;
> +       const skb_frag_t *frags = NULL;
> +       u32 length = 0, seq, offset;
> +       struct vm_area_struct *vma;
> +       struct sk_buff *skb = NULL;
>         struct tcp_sock *tp;
> -       struct sk_buff *skb;
>         int ret;
>
> -       if (vma->vm_pgoff || !nr_pages)
> +       if (address & (PAGE_SIZE - 1) || address != zc->address)
>                 return -EINVAL;
>
> -       if (vma->vm_flags & VM_WRITE)
> -               return -EPERM;
> -       /* TODO: Maybe the following is not needed if pages are COW */
> -       vma->vm_flags &= ~VM_MAYWRITE;
> -
> -       lock_sock(sk);
> -
> -       ret = -ENOTCONN;
>         if (sk->sk_state == TCP_LISTEN)
> -               goto out;
> +               return -ENOTCONN;
>
>         sock_rps_record_flow(sk);
>
> -       if (tcp_inq(sk) < size) {
> -               ret = sock_flag(sk, SOCK_DONE) ? -EIO : -EAGAIN;
> +       down_read(&current->mm->mmap_sem);
> +
> +       ret = -EINVAL;
> +       vma = find_vma(current->mm, address);
> +       if (!vma || vma->vm_start > address || vma->vm_ops != &tcp_vm_ops)
>                 goto out;
> -       }
> +       zc->length = min_t(unsigned long, zc->length, vma->vm_end - address);
> +
>         tp = tcp_sk(sk);
>         seq = tp->copied_seq;
> -       /* Abort if urgent data is in the area */
> -       if (unlikely(tp->urg_data)) {
> -               u32 urg_offset = tp->urg_seq - seq;
> +       zc->length = min_t(u32, zc->length, tcp_inq(sk));
> +       zc->length &= ~(PAGE_SIZE - 1);
>
> -               ret = -EINVAL;
> -               if (urg_offset < size)
> -                       goto out;
> -       }
> -       ret = -ENOMEM;
> -       pages_array = kvmalloc_array(nr_pages, sizeof(struct page *),
> -                                    GFP_KERNEL);
> -       if (!pages_array)
> -               goto out;
> -       skb = tcp_recv_skb(sk, seq, &offset);
> -       ret = -EINVAL;
> -skb_start:
> -       /* We do not support anything not in page frags */
> -       offset -= skb_headlen(skb);
> -       if ((int)offset < 0)
> -               goto out;
> -       if (skb_has_frag_list(skb))
> -               goto out;
> -       len = skb->data_len - offset;
> -       frags = skb_shinfo(skb)->frags;
> -       while (offset) {
> -               if (frags->size > offset)
> -                       goto out;
> -               offset -= frags->size;
> -               frags++;
> -       }
> -       while (nr < nr_pages) {
> -               if (len) {
> -                       if (len < PAGE_SIZE)
> -                               goto out;
> -                       if (frags->size != PAGE_SIZE || frags->page_offset)
> -                               goto out;
> -                       pages_array[nr++] = skb_frag_page(frags);
> -                       frags++;
> -                       len -= PAGE_SIZE;
> -                       seq += PAGE_SIZE;
> -                       continue;
> -               }
> -               skb = skb->next;
> -               offset = seq - TCP_SKB_CB(skb)->seq;
> -               goto skb_start;
> -       }
> -       /* OK, we have a full set of pages ready to be inserted into vma */
> -       for (nr = 0; nr < nr_pages; nr++) {
> -               ret = vm_insert_page(vma, vma->vm_start + (nr << PAGE_SHIFT),
> -                                    pages_array[nr]);
> -               if (ret)
> -                       goto out;
> -       }
> -       /* operation is complete, we can 'consume' all skbs */
> -       tp->copied_seq = seq;
> -       tcp_rcv_space_adjust(sk);
> -
> -       /* Clean up data we have read: This will do ACK frames. */
> -       tcp_recv_skb(sk, seq, &offset);
> -       tcp_cleanup_rbuf(sk, size);
> +       zap_page_range(vma, address, zc->length);
>
> +       zc->recv_skip_hint = 0;
>         ret = 0;
> +       while (length + PAGE_SIZE <= zc->length) {
> +               if (zc->recv_skip_hint < PAGE_SIZE) {
> +                       if (skb) {
> +                               skb = skb->next;
> +                               offset = seq - TCP_SKB_CB(skb)->seq;
> +                       } else {
> +                               skb = tcp_recv_skb(sk, seq, &offset);
> +                       }
> +
> +                       zc->recv_skip_hint = skb->len - offset;
> +                       offset -= skb_headlen(skb);
> +                       if ((int)offset < 0 || skb_has_frag_list(skb))
> +                               break;
> +                       frags = skb_shinfo(skb)->frags;
> +                       while (offset) {
> +                               if (frags->size > offset)
> +                                       goto out;
> +                               offset -= frags->size;
> +                               frags++;
> +                       }
> +               }
> +               if (frags->size != PAGE_SIZE || frags->page_offset)
> +                       break;
> +               ret = vm_insert_page(vma, address + length,
> +                                    skb_frag_page(frags));
> +               if (ret)
> +                       break;
> +               length += PAGE_SIZE;
> +               seq += PAGE_SIZE;
> +               zc->recv_skip_hint -= PAGE_SIZE;
> +               frags++;
> +       }
>  out:
> -       release_sock(sk);
> -       kvfree(pages_array);
> +       up_read(&current->mm->mmap_sem);
> +       if (length) {
> +               tp->copied_seq = seq;
> +               tcp_rcv_space_adjust(sk);
> +
> +               /* Clean up data we have read: This will do ACK frames. */
> +               tcp_recv_skb(sk, seq, &offset);
> +               tcp_cleanup_rbuf(sk, length);
> +               ret = 0;
> +               if (length == zc->length)
> +                       zc->recv_skip_hint = 0;
> +       } else {
> +               if (!zc->recv_skip_hint && sock_flag(sk, SOCK_DONE))
> +                       ret = -EIO;
> +       }
> +       zc->length = length;
>         return ret;
>  }
> -EXPORT_SYMBOL(tcp_mmap);
>
>  static void tcp_update_recv_tstamps(struct sk_buff *skb,
>                                     struct scm_timestamping *tss)
> @@ -3472,6 +3465,23 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>                 }
>                 return 0;
>         }
> +       case TCP_ZEROCOPY_RECEIVE: {
> +               struct tcp_zerocopy_receive zc;
> +               int err;
> +
> +               if (get_user(len, optlen))
> +                       return -EFAULT;
> +               if (len != sizeof(zc))
> +                       return -EINVAL;
> +               if (copy_from_user(&zc, optval, len))
> +                       return -EFAULT;
> +               lock_sock(sk);
> +               err = tcp_zerocopy_receive(sk, &zc);
> +               release_sock(sk);
> +               if (!err && copy_to_user(optval, &zc, len))
> +                       err = -EFAULT;
> +               return err;
> +       }
>         default:
>                 return -ENOPROTOOPT;
>         }
> --
> 2.17.0.484.g0c8726318c-goog
>
