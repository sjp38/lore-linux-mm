Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7EEED6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 04:59:56 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id r129so123939770wmr.0
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 01:59:56 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id 12si52527257wjy.50.2016.01.20.01.59.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 01:59:55 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 20 Jan 2016 09:59:54 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 4BE331B0804B
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 09:59:56 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0K9xpgb1048980
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 09:59:51 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0K9xoP0003772
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 02:59:51 -0700
Date: Wed, 20 Jan 2016 10:59:49 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: Mlocked pages statistics shows bogus value.
Message-ID: <20160120095949.GE3395@osiris>
References: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
 <20160119122101.GA20260@node.shutemov.name>
 <201601192146.IFE86479.VMHLOFtQSOFFJO@I-love.SAKURA.ne.jp>
 <20160119130137.GA20984@node.shutemov.name>
 <201601192238.CEH73964.MOtFFLJVOOSHQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601192238.CEH73964.MOtFFLJVOOSHQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: kirill@shutemov.name, walken@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, "Huang, Ying" <ying.huang@intel.com>

(added "Huang, Ying" <ying.huang@intel.com> to cc.)

On Tue, Jan 19, 2016 at 10:38:50PM +0900, Tetsuo Handa wrote:
> Kirill A. Shutemov wrote:
> > On Tue, Jan 19, 2016 at 09:46:21PM +0900, Tetsuo Handa wrote:
> > > Kirill A. Shutemov wrote:
> > > > Oh. Looks like a bug from 2013...
> > > > 
> > > > Thanks for report.
> > > > For unsigned int nr_pages, implicitly casted to long in
> > > > __mod_zone_page_state(), it becomes something around UINT_MAX.
> > > > 
> > > > munlock_vma_page() usually called for THP as small pages go though
> > > > pagevec.
> > > > 
> > > > Let's make nr_pages singed int.
> > > > 
> > > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > Fixes: ff6a6da60b89 ("mm: accelerate munlock() treatment of THP pages")
> > > > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > > Cc: Michel Lespinasse <walken@google.com>
> > > > ---
> > > >  mm/mlock.c | 2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > 
> > > > diff --git a/mm/mlock.c b/mm/mlock.c
> > > > index e1e2b1207bf2..96f001041928 100644
> > > > --- a/mm/mlock.c
> > > > +++ b/mm/mlock.c
> > > > @@ -175,7 +175,7 @@ static void __munlock_isolation_failed(struct page *page)
> > > >   */
> > > >  unsigned int munlock_vma_page(struct page *page)
> > > >  {
> > > > -	unsigned int nr_pages;
> > > > +	int nr_pages;
> > > >  	struct zone *zone = page_zone(page);
> > > >  
> > > >  	/* For try_to_munlock() and to serialize with page migration */
> > > > -- 
> > > >  Kirill A. Shutemov
> > > > 
> 
> I tested your patch on Linux 4.4 and confirmed that your patch fixed this bug.
> Please also send to stable.
> 
> Cc: <stable@vger.kernel.org>  [4.4+]
> 
> > > Don't we want to use "long" than "int" for all variables that count number
> > > of pages, for recently commit 6cdb18ad98a49f7e9b95d538a0614cde827404b8
> > > "mm/vmstat: fix overflow in mod_zone_page_state()" changed to use "long" ?
> > 
> > Potentially, yes. But here we count number of small pages in the compound
> > page. We're far from being able to allocate 8 terabyte pages ;)
> 
> That commit says "we have a 9TB system with only one node".
> You might encounter such machines in near future. ;-)
> 
> > 
> > Anyway, it's out-of-scope for this bug fix.
> > 
> > My "Fixes:" is probably misleading, since we don't have bug visible until
> > 6cdb18ad98a4.

Please also mention 6cdb18ad98a4 in the changelog. I didn't request to add
my "obviously correct" ;) patch to be added to -stable.
But just in case somebody backports it..

There was also a performance regression reported that was introduced with
6cdb18ad98a4. However I couldn't make any sense of it. Maybe this patch
fixes it also?

See https://lkml.org/lkml/2016/1/5/1103

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
