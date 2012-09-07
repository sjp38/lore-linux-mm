Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id CE6306B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 18:38:27 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so83356ghr.14
        for <linux-mm@kvack.org>; Fri, 07 Sep 2012 15:38:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
References: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 7 Sep 2012 18:38:06 -0400
Message-ID: <CAHGf_=o8VzFSF3kGK92bKgeWPJ4qOQ_NhCzXO-J_Ge22M7M20g@mail.gmail.com>
Subject: Re: [PATCH] mm: fix mmap overflow checking
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Sep 4, 2012 at 5:23 AM, Wanlong Gao <gaowanlong@cn.fujitsu.com> wrote:
> POSIX said that if the file is a regular file and the value of "off"
> plus "len" exceeds the offset maximum established in the open file
> description associated with fildes, mmap should return EOVERFLOW.
>
> The following test from LTP can reproduce this bug.
>
>         char tmpfname[256];
>         void *pa = NULL;
>         void *addr = NULL;
>         size_t len;
>         int flag;
>         int fd;
>         off_t off = 0;
>         int prot;
>
>         long page_size = sysconf(_SC_PAGE_SIZE);
>
>         snprintf(tmpfname, sizeof(tmpfname), "/tmp/mmap_test_%d", getpid());
>         unlink(tmpfname);
>         fd = open(tmpfname, O_CREAT | O_RDWR | O_EXCL, S_IRUSR | S_IWUSR);
>         if (fd == -1) {
>                 printf(" Error at open(): %s\n", strerror(errno));
>                 return 1;
>         }
>         unlink(tmpfname);
>
>         flag = MAP_SHARED;
>         prot = PROT_READ | PROT_WRITE;
>
>         /* len + off > maximum offset */
>
>         len = ULONG_MAX;
>         if (len % page_size) {
>                 /* Lower boundary */
>                 len &= ~(page_size - 1);
>         }
>
>         off = ULONG_MAX;
>         if (off % page_size) {
>                 /* Lower boundary */
>                 off &= ~(page_size - 1);
>         }
>
>         printf("off: %lx, len: %lx\n", (unsigned long)off, (unsigned long)len);
>         pa = mmap(addr, len, prot, flag, fd, off);
>         if (pa == MAP_FAILED && errno == EOVERFLOW) {
>                 printf("Test Pass: Error at mmap: %s\n", strerror(errno));
>                 return 0;
>         }
>
>         if (pa == MAP_FAILED)
>                 perror("Test FAIL: expect EOVERFLOW but get other error");
>         else
>                 printf("Test FAIL : Expect EOVERFLOW but got no error\n");
>
>         close(fd);
>         munmap(pa, len);
>         return 1;
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: linux-mm@kvack.org (open list:MEMORY MANAGEMENT)
> Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
> ---
>  mm/mmap.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index ae18a48..5380764 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -980,6 +980,7 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
>         struct mm_struct * mm = current->mm;
>         struct inode *inode;
>         vm_flags_t vm_flags;
> +       off_t off = pgoff << PAGE_SHIFT;

I've seen the exactly same patch from another fujitsu guys several
month ago. and as I pointed
out at that time, this line don't work when 32bit kernel + mmap2 syscall case.

Please don't think do_mmap_pgoff() is for mmap(2) specific and read a
past thread before resend
a patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
