Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id DDB1E6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 11:09:20 -0400 (EDT)
Received: by wicge2 with SMTP id ge2so5040484wic.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:09:20 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id mz9si8246303wic.47.2015.08.27.08.09.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 08:09:18 -0700 (PDT)
Received: by wicgk12 with SMTP id gk12so11758340wic.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 08:09:18 -0700 (PDT)
Date: Thu, 27 Aug 2015 17:09:17 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150827150917.GF27052@dhcp22.suse.cz>
References: <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1508261104000.1975@eggly.anvils>
 <20150826212916.GG11078@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150826212916.GG11078@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Wed 26-08-15 14:29:16, Paul E. McKenney wrote:
> On Wed, Aug 26, 2015 at 11:18:45AM -0700, Hugh Dickins wrote:
[...]
> > But if you do one day implement that, wouldn't sl?b.c have to use
> > call_rcu_with_added_meaning() instead of call_rcu(), to be in danger
> > of getting that bit set?  (No rcu_head is placed in a PageTail page.)
> 
> Good point, call_rcu_lazy(), but yes.
> 
> > So although it might be a little strange not to use a variant intended
> > for freeing memory when indeed that's what it's doing, it would not be
> > the end of the world for SLAB_DESTROY_BY_RCU to carry on using straight
> > call_rcu(), in defence of the struct page safety Kirill is proposing.
> 
> As long as you are OK with the bottom bit being zero throughout the RCU
> processing, yes.

I am really not sure I udnerstand. What will prevent
call_rcu(&page->rcu_head, free_page_rcu) done in a random driver?

Cannot the RCU simply claim bit1? I can see 1146edcbef37 ("rcu: Loosen
__call_rcu()'s rcu_head alignment constraint") but AFAIU all it would
take to fix this would be to require struct rcu_head to be aligned to
32b no?

Btw. Do we need the same think for page::mapping and KSM?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
