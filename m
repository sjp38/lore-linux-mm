Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 1ABE06B00AD
	for <linux-mm@kvack.org>; Tue, 14 May 2013 10:46:10 -0400 (EDT)
Date: Tue, 14 May 2013 10:46:02 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH v5 2/8] vmcore: clean up read_vmcore()
Message-ID: <20130514144602.GB16772@redhat.com>
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6>
 <20130514015717.18697.43144.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130514015717.18697.43144.stgit@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org

On Tue, May 14, 2013 at 10:57:17AM +0900, HATAYAMA Daisuke wrote:
> Rewrite part of read_vmcore() that reads objects in vmcore_list in the
> same way as part reading ELF headers, by which some duplicated and
> redundant codes are removed.
> 
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>

Looks good to me.

Acked-by: Vivek Goyal <vgoyal@redhat.com>

Vivek

> ---
> 
>  fs/proc/vmcore.c |   68 ++++++++++++++++--------------------------------------
>  1 files changed, 20 insertions(+), 48 deletions(-)
> 
> diff --git a/fs/proc/vmcore.c b/fs/proc/vmcore.c
> index 69e1198..48886e6 100644
> --- a/fs/proc/vmcore.c
> +++ b/fs/proc/vmcore.c
> @@ -119,27 +119,6 @@ static ssize_t read_from_oldmem(char *buf, size_t count,
>  	return read;
>  }
>  
> -/* Maps vmcore file offset to respective physical address in memroy. */
> -static u64 map_offset_to_paddr(loff_t offset, struct list_head *vc_list,
> -					struct vmcore **m_ptr)
> -{
> -	struct vmcore *m;
> -	u64 paddr;
> -
> -	list_for_each_entry(m, vc_list, list) {
> -		u64 start, end;
> -		start = m->offset;
> -		end = m->offset + m->size - 1;
> -		if (offset >= start && offset <= end) {
> -			paddr = m->paddr + offset - start;
> -			*m_ptr = m;
> -			return paddr;
> -		}
> -	}
> -	*m_ptr = NULL;
> -	return 0;
> -}
> -
>  /* Read from the ELF header and then the crash dump. On error, negative value is
>   * returned otherwise number of bytes read are returned.
>   */
> @@ -148,8 +127,8 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
>  {
>  	ssize_t acc = 0, tmp;
>  	size_t tsz;
> -	u64 start, nr_bytes;
> -	struct vmcore *curr_m = NULL;
> +	u64 start;
> +	struct vmcore *m = NULL;
>  
>  	if (buflen == 0 || *fpos >= vmcore_size)
>  		return 0;
> @@ -175,33 +154,26 @@ static ssize_t read_vmcore(struct file *file, char __user *buffer,
>  			return acc;
>  	}
>  
> -	start = map_offset_to_paddr(*fpos, &vmcore_list, &curr_m);
> -	if (!curr_m)
> -        	return -EINVAL;
> -
> -	while (buflen) {
> -		tsz = min_t(size_t, buflen, PAGE_SIZE - (start & ~PAGE_MASK));
> -
> -		/* Calculate left bytes in current memory segment. */
> -		nr_bytes = (curr_m->size - (start - curr_m->paddr));
> -		if (tsz > nr_bytes)
> -			tsz = nr_bytes;
> -
> -		tmp = read_from_oldmem(buffer, tsz, &start, 1);
> -		if (tmp < 0)
> -			return tmp;
> -		buflen -= tsz;
> -		*fpos += tsz;
> -		buffer += tsz;
> -		acc += tsz;
> -		if (start >= (curr_m->paddr + curr_m->size)) {
> -			if (curr_m->list.next == &vmcore_list)
> -				return acc;	/*EOF*/
> -			curr_m = list_entry(curr_m->list.next,
> -						struct vmcore, list);
> -			start = curr_m->paddr;
> +	list_for_each_entry(m, &vmcore_list, list) {
> +		if (*fpos < m->offset + m->size) {
> +			tsz = m->offset + m->size - *fpos;
> +			if (buflen < tsz)
> +				tsz = buflen;
> +			start = m->paddr + *fpos - m->offset;
> +			tmp = read_from_oldmem(buffer, tsz, &start, 1);
> +			if (tmp < 0)
> +				return tmp;
> +			buflen -= tsz;
> +			*fpos += tsz;
> +			buffer += tsz;
> +			acc += tsz;
> +
> +			/* leave now if filled buffer already */
> +			if (buflen == 0)
> +				return acc;
>  		}
>  	}
> +
>  	return acc;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
