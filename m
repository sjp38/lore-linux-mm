Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 9120D6B007B
	for <linux-mm@kvack.org>; Wed,  8 May 2013 16:48:28 -0400 (EDT)
Date: Wed, 08 May 2013 16:48:13 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1368046093-mpzcumyb-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130508184524.GF30955@pd.tnic>
References: <20130508143411.GD30955@pd.tnic>
 <1368029552-dzvitovl-mutt-n-horiguchi@ah.jp.nec.com>
 <20130508184524.GF30955@pd.tnic>
Subject: [PATCH] ipc/shm.c: don't use auto variable hs in newseg()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Wed, May 08, 2013 at 08:45:24PM +0200, Borislav Petkov wrote:
> On Wed, May 08, 2013 at 12:12:32PM -0400, Naoya Horiguchi wrote:
> > Thank you for the report.
> > I believe we can fix it with this one.
> > ---
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Wed, 8 May 2013 11:48:01 -0400
> > Subject: [PATCH] ipc/shm.c: don't use auto variable hs in newseg()
> > 
> > This patch fixes "warning: unused variable 'hs'" when !CONFIG_HUGETLB_PAGE
> > introduced by commit af73e4d9506d "hugetlbfs: fix mmap failure in unaligned
> > size request".
> > 
> > Reported-by: Borislav Petkov <bp@alien8.de>
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  ipc/shm.c | 5 ++---
> >  1 file changed, 2 insertions(+), 3 deletions(-)
> > 
> > diff --git a/ipc/shm.c b/ipc/shm.c
> > index e316cb9..9ff741a 100644
> > --- a/ipc/shm.c
> > +++ b/ipc/shm.c
> > @@ -491,9 +491,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> >  
> >  	sprintf (name, "SYSV%08x", key);
> >  	if (shmflg & SHM_HUGETLB) {
> > -		struct hstate *hs = hstate_sizelog((shmflg >> SHM_HUGE_SHIFT)
> > -						& SHM_HUGE_MASK);
> > -		size_t hugesize = ALIGN(size, huge_page_size(hs));
> > +		size_t hugesize = ALIGN(size, huge_page_size(hstate_sizelog(
> > +				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK)));
> 
> Yeah, it fixes the warning alright but makes the code more unreadable.
> Which makes me wonder which is worse - to have an innocuous warning or
> have unreadable code.
> 
> You could also do the below. The line sticks out but it kills the
> warning. Readability is hmm, not optimal still though. :)
> --
> diff --git a/ipc/shm.c b/ipc/shm.c
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -491,9 +491,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  
>  	sprintf (name, "SYSV%08x", key);
>  	if (shmflg & SHM_HUGETLB) {
> -		struct hstate *hs = hstate_sizelog((shmflg >> SHM_HUGE_SHIFT)
> -						& SHM_HUGE_MASK);
> -		size_t hugesize = ALIGN(size, huge_page_size(hs));
> +		unsigned long hsz = huge_page_size(hstate_sizelog((shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK));
> +		size_t hugesize = ALIGN(size, hsz);
>  
>  		/* hugetlb_file_setup applies strict accounting */
>  		if (shmflg & SHM_NORESERVE)
> --
> 
> Yeah, you decide.

(CCed: Andrew and linux-mm)
OK, personally both are OK (comparably bad) for me, so I'll do the same
as af73e4d9506d3b does for SYSCALL_DEFINE6(mmap_pgoff), where we have
a line break just after '('.

Andrew, could you pick up the following fix?
-----
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Wed, 8 May 2013 11:48:01 -0400
Subject: [PATCH] ipc/shm.c: don't use auto variable hs in newseg()

This patch fixes "warning: unused variable 'hs'" when !CONFIG_HUGETLB_PAGE
introduced by commit af73e4d9506d "hugetlbfs: fix mmap failure in unaligned
size request".

Reported-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 ipc/shm.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/ipc/shm.c b/ipc/shm.c
index e316cb9..9ff741a 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -491,9 +491,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
 
 	sprintf (name, "SYSV%08x", key);
 	if (shmflg & SHM_HUGETLB) {
-		struct hstate *hs = hstate_sizelog((shmflg >> SHM_HUGE_SHIFT)
-						& SHM_HUGE_MASK);
-		size_t hugesize = ALIGN(size, huge_page_size(hs));
+		size_t hugesize = ALIGN(size, huge_page_size(hstate_sizelog(
+				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK)));
 
 		/* hugetlb_file_setup applies strict accounting */
 		if (shmflg & SHM_NORESERVE)
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
