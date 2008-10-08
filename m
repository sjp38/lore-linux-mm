Received: by rv-out-0708.google.com with SMTP id f25so3324139rvb.26
        for <linux-mm@kvack.org>; Wed, 08 Oct 2008 01:57:21 -0700 (PDT)
Message-ID: <517f3f820810080157j3994ff10j8518178af02e5b22@mail.gmail.com>
Date: Wed, 8 Oct 2008 10:57:21 +0200
From: "Michael Kerrisk" <mtk.manpages@gmail.com>
Subject: Re: [PATCH, v3] shmat: introduce flag SHM_MAP_NOT_FIXED
In-Reply-To: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1223396117-8118-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ulrich Drepper <drepper@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Kirill,

On Tue, Oct 7, 2008 at 6:15 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> If SHM_MAP_NOT_FIXED specified and shmaddr is not NULL, then the kernel takes
> shmaddr as a hint about where to place the mapping. The address of the mapping
> is returned as the result of the call.
>
> It's similar to mmap() without MAP_FIXED.

Please CC linux-api@vger.kernel.org on patches that change the
kernel-userspace interface.

Cheers,

Michael

> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Andi Kleen <andi@firstfloor.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Arjan van de Ven <arjan@infradead.org>
> Cc: Hugh Dickins <hugh@veritas.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Cc: Ulrich Drepper <drepper@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/shm.h |    2 ++
>  ipc/shm.c           |    7 ++++---
>  2 files changed, 6 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index eca6235..fd288eb 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -55,6 +55,8 @@ struct shmid_ds {
>  #define        SHM_RND         020000  /* round attach address to SHMLBA boundary */
>  #define        SHM_REMAP       040000  /* take-over region on attach */
>  #define        SHM_EXEC        0100000 /* execution access */
> +#define        SHM_MAP_NOT_FIXED 0200000 /* interpret attach address as a search
> +                                  * hint */
>
>  /* super user shmctl commands */
>  #define SHM_LOCK       11
> diff --git a/ipc/shm.c b/ipc/shm.c
> index e77ec69..54f3c61 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -819,7 +819,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
>        if (shmid < 0)
>                goto out;
>        else if ((addr = (ulong)shmaddr)) {
> -               if (addr & (SHMLBA-1)) {
> +               if (!(shmflg & SHM_MAP_NOT_FIXED) && (addr & (SHMLBA-1))) {
>                        if (shmflg & SHM_RND)
>                                addr &= ~(SHMLBA-1);       /* round down */
>                        else
> @@ -828,7 +828,8 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
>  #endif
>                                        goto out;
>                }
> -               flags = MAP_SHARED | MAP_FIXED;
> +               flags = MAP_SHARED |
> +                               (shmflg & SHM_MAP_NOT_FIXED ? 0 : MAP_FIXED);
>        } else {
>                if ((shmflg & SHM_REMAP))
>                        goto out;
> @@ -892,7 +893,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
>        sfd->vm_ops = NULL;
>
>        down_write(&current->mm->mmap_sem);
> -       if (addr && !(shmflg & SHM_REMAP)) {
> +       if (addr && !(shmflg & (SHM_REMAP|SHM_MAP_NOT_FIXED))) {
>                err = -EINVAL;
>                if (find_vma_intersection(current->mm, addr, addr + size))
>                        goto invalid;
> --
> 1.5.6.5.GIT
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/ Found a documentation bug?
http://www.kernel.org/doc/man-pages/reporting_bugs.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
