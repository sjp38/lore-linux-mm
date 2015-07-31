Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 382F06B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 06:28:06 -0400 (EDT)
Received: by ioii16 with SMTP id i16so80968978ioi.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 03:28:06 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0141.hostedemail.com. [216.40.44.141])
        by mx.google.com with ESMTP id l9si2679336igx.102.2015.07.31.03.28.05
        for <linux-mm@kvack.org>;
        Fri, 31 Jul 2015 03:28:05 -0700 (PDT)
Message-ID: <1438338481.19675.72.camel@perches.com>
Subject: Re: [PATCH 14/15] mm: Drop unlikely before IS_ERR(_OR_NULL)
From: Joe Perches <joe@perches.com>
Date: Fri, 31 Jul 2015 03:28:01 -0700
In-Reply-To: <20150731093450.GA7505@linux>
References: <cover.1438331416.git.viresh.kumar@linaro.org>
	 <91586af267deb26b905fba61a9f1f665a204a4e3.1438331416.git.viresh.kumar@linaro.org>
	 <20150731085646.GA31544@node.dhcp.inet.fi>
	 <FA3D9AE9-9D1E-4232-87DE-42F21B408B24@gmail.com>
	 <20150731093450.GA7505@linux>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: yalin wang <yalin.wang2010@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linaro-kernel@lists.linaro.org, open list <linux-kernel@vger.kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>

On Fri, 2015-07-31 at 15:04 +0530, Viresh Kumar wrote:
> On 31-07-15, 17:32, yalin wang wrote:
> > 
> > > On Jul 31, 2015, at 16:56, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > > 
> > > On Fri, Jul 31, 2015 at 02:08:34PM +0530, Viresh Kumar wrote:
> > >> IS_ERR(_OR_NULL) already contain an 'unlikely' compiler flag and there
> > >> is no need to do that again from its callers. Drop it.
> > >> 
> > >> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
> > > 
> > > Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> > search in code, there are lots of using like this , does need add this check into checkpatch ?
> 
> cc'd Joe for that. :)
> 
> > # grep -r 'likely.*IS_ERR'  .
> > ./include/linux/blk-cgroup.h:	if (unlikely(IS_ERR(blkg)))
> > ./fs/nfs/objlayout/objio_osd.c:	if (unlikely(IS_ERR(od))) {
> > ./fs/cifs/readdir.c:	if (unlikely(IS_ERR(dentry)))
> > ./fs/ext4/extents.c:		if (unlikely(IS_ERR(bh))) {
> > ./fs/ext4/extents.c:		if (unlikely(IS_ERR(path1))) {
> > ./fs/ext4/extents.c:		if (unlikely(IS_ERR(path2))) {
> 
> Btw, my series has fixed all of them :)

If it's all fixed, then it's unlikely to be needed in checkpatch.

But given the unlikely was added when using gcc3.4, I wonder if
it's still appropriate to use unlikely in IS_ERR at all.

---

commit b5acea523151452c37cd428437e7576a291dd146
Author: Andrew Morton <akpm@osdl.org>
Date:   Sun Aug 22 23:04:49 2004 -0700

    [PATCH] mark IS_ERR as unlikely()
    
    It seems fair to assume that it is always unlikely that IS_ERR will return
    true.
    
    This patch changes the gcc-3.4-generated kernel text by ~500 bytes (less) so
    it's fair to assume that the compiler is indeed propagating unlikeliness out
    of inline functions.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
