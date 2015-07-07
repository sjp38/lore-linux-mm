Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 197879003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 04:12:43 -0400 (EDT)
Received: by wgck11 with SMTP id k11so160657237wgc.0
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 01:12:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bv2si34755956wjc.100.2015.07.07.01.12.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Jul 2015 01:12:41 -0700 (PDT)
Date: Tue, 7 Jul 2015 09:12:33 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mm/page_alloc.c:247:6: warning: unused variable 'nid'
Message-ID: <20150707081233.GK6812@suse.de>
References: <201507041743.GoTZWMrj%fengguang.wu@intel.com>
 <20150704181008.GA1374@node.dhcp.inet.fi>
 <20150706150509.48abfb09376605d611ceadbe@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150706150509.48abfb09376605d611ceadbe@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jul 06, 2015 at 03:05:09PM -0700, Andrew Morton wrote:
> On Sat, 4 Jul 2015 21:10:08 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Sat, Jul 04, 2015 at 05:26:47PM +0800, kbuild test robot wrote:
> > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > > head:   14a6f1989dae9445d4532941bdd6bbad84f4c8da
> > > commit: 3b242c66ccbd60cf47ab0e8992119d9617548c23 x86: mm: enable deferred struct page initialisation on x86-64
> > > date:   3 days ago
> > > config: x86_64-randconfig-x006-201527 (attached as .config)
> > > reproduce:
> > >   git checkout 3b242c66ccbd60cf47ab0e8992119d9617548c23
> > >   # save the attached .config to linux build tree
> > >   make ARCH=x86_64 
> > > 
> > > All warnings (new ones prefixed by >>):
> > > 
> > >    mm/page_alloc.c: In function 'early_page_uninitialised':
> > > >> mm/page_alloc.c:247:6: warning: unused variable 'nid' [-Wunused-variable]
> > >      int nid = early_pfn_to_nid(pfn);
> > 
> > We can silence the warning with something like patch below. But I'm not
> > sure it worth it.
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 754c25966a0a..746a6a7b0535 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -911,7 +911,7 @@ extern char numa_zonelist_order[];
> >  #ifndef CONFIG_NEED_MULTIPLE_NODES
> >  
> >  extern struct pglist_data contig_page_data;
> > -#define NODE_DATA(nid)         (&contig_page_data)
> > +#define NODE_DATA(nid)         ((void)nid, &contig_page_data)
> >  #define NODE_MEM_MAP(nid)      mem_map
> >  
> >  #else /* CONFIG_NEED_MULTIPLE_NODES */
> 
> Sigh.  Macros do suck.  If NODE_DATA was a regular old C function this
> warning wouldn't occur.  Problem is, we should then rename it to
> "node_data" and that would require 246 edits.
> 
> I suppose we could compromise and do 
> 
> 	static inline struct pglist_data *NODE_DATA(int nid)
> 
> ?

It might set a bad precedent. While I know there are counter examples,
I generally expect CAPITAL_NAMES to be macros of some description --
usually constants. This is a relatively harmless warning thats easy to
work around so how about this?

---8<---
mm, meminit: Suppress unused memory variable warning

The kbuild test robot reported the following

  tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
  head:   14a6f1989dae9445d4532941bdd6bbad84f4c8da
  commit: 3b242c66ccbd60cf47ab0e8992119d9617548c23 x86: mm: enable deferred struct page initialisation on x86-64
  date:   3 days ago
  config: x86_64-randconfig-x006-201527 (attached as .config)
  reproduce:
    git checkout 3b242c66ccbd60cf47ab0e8992119d9617548c23
    # save the attached .config to linux build tree
    make ARCH=x86_64

  All warnings (new ones prefixed by >>):

     mm/page_alloc.c: In function 'early_page_uninitialised':
  >> mm/page_alloc.c:247:6: warning: unused variable 'nid' [-Wunused-variable]
       int nid = early_pfn_to_nid(pfn);

It's due to the NODE_DATA macro ignoring the nid parameter on !NUMA
configurations. This patch avoids the warning by not declaring nid.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 506eac8b38af..ac05e7ae399e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -246,9 +246,7 @@ static inline void reset_deferred_meminit(pg_data_t *pgdat)
 /* Returns true if the struct page for the pfn is uninitialised */
 static inline bool __meminit early_page_uninitialised(unsigned long pfn)
 {
-	int nid = early_pfn_to_nid(pfn);
-
-	if (pfn >= NODE_DATA(nid)->first_deferred_pfn)
+	if (pfn >= NODE_DATA(early_pfn_to_nid(pfn))->first_deferred_pfn)
 		return true;
 
 	return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
