Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 6E0C56B0068
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 07:24:21 -0500 (EST)
Date: Thu, 3 Jan 2013 13:24:17 +0100
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v7 1/2] KSM: numa awareness sysfs knob
Message-ID: <20130103122416.GB2277@thinkpad-work.redhat.com>
References: <20121224050817.GA25749@kroah.com>
 <1356658337-12540-1-git-send-email-pholasek@redhat.com>
 <1357015310.1379.2.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357015310.1379.2.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

Hi Simon,

On Mon, 31 Dec 2012, Simon Jeons wrote:
> On Fri, 2012-12-28 at 02:32 +0100, Petr Holasek wrote:
> > 
> > v7:	- added sysfs ABI documentation for KSM
> 
> Hi Petr,
> 
> How you handle "memory corruption because the ksm page still points to
> the stable_node that has been freed" mentioned by Andrea this time?
> 

<snip>

> >  
> > +		/*
> > +		 * If tree_page has been migrated to another NUMA node, it
> > +		 * will be flushed out and put into the right unstable tree
> > +		 * next time: only merge with it if merge_across_nodes.
> 
> Why? Do you mean swap based migration? Or where I miss ....?
> 

It can be physical page migration triggered by page compaction, memory hotplug
or some NUMA sched/memory balancing algorithm developed recently.

> > +		 * Just notice, we don't have similar problem for PageKsm
> > +		 * because their migration is disabled now. (62b61f611e)
> > +		 */

Migration of KSM pages is disabled now, you can look into ^^^ commit and
changes introduced to migrate.c.

> > +		if (!ksm_merge_across_nodes && page_to_nid(tree_page) != nid) {
> > +			put_page(tree_page);
> > +			return NULL;
> > +		}
> > +
> >  		ret = memcmp_pages(page, tree_page);

</snip>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
