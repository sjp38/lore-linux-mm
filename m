Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 9D5936B0032
	for <linux-mm@kvack.org>; Fri, 17 May 2013 21:47:00 -0400 (EDT)
Date: Fri, 17 May 2013 21:46:37 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1368841597-8mnfve1j-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <519693B8.10600@gmail.com>
References: <20130508143411.GD30955@pd.tnic>
 <1368029552-dzvitovl-mutt-n-horiguchi@ah.jp.nec.com>
 <20130508184524.GF30955@pd.tnic>
 <1368046093-mpzcumyb-mutt-n-horiguchi@ah.jp.nec.com>
 <519693B8.10600@gmail.com>
Subject: Re: [PATCH] ipc/shm.c: don't use auto variable hs in newseg()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, May 17, 2013 at 04:31:52PM -0400, KOSAKI Motohiro wrote:
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
> NAK. This is uglier than before.
> You should change !CONFIG_HUGETLB_PAGE specific code instead.

This patch was dropped and replaced with Li Zefan's one which is
available in current upstream.

  commit 091d0d55b286c9340201b4ed4470be87fc568228
  Author: Li Zefan <lizefan@huawei.com>
  Date:   Thu May 9 15:08:15 2013 +0800

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
