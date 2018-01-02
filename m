Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 753936B02C4
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 15:24:28 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id j60so39405454qtb.20
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 12:24:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z50si5538867qtb.99.2018.01.02.12.24.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 12:24:27 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w02KJo42039525
	for <linux-mm@kvack.org>; Tue, 2 Jan 2018 15:24:26 -0500
Received: from e13.ny.us.ibm.com (e13.ny.us.ibm.com [129.33.205.203])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2f8d49rnhp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Jan 2018 15:24:25 -0500
Received: from localhost
	by e13.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 2 Jan 2018 15:24:24 -0500
Date: Tue, 2 Jan 2018 12:24:54 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] Move kfree_call_rcu() to slab_common.c
Reply-To: paulmck@linux.vnet.ibm.com
References: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
 <20171221123630.GB22405@bombadil.infradead.org>
 <44044955-1ef9-1d1e-5311-d8edc006b812@oracle.com>
 <20171222013937.GA7829@linux.vnet.ibm.com>
 <106f9cdb-bb0b-539d-547e-18c509ca1163@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <106f9cdb-bb0b-539d-547e-18c509ca1163@oracle.com>
Message-Id: <20180102202454.GQ7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Thu, Dec 21, 2017 at 07:17:35PM -0800, Rao Shoaib wrote:
> 
> 
> On 12/21/2017 05:39 PM, Paul E. McKenney wrote:
> >>I left it out on purpose because the call in tiny is a little different
> >>
> >>rcutiny.h:
> >>
> >>static inline void kfree_call_rcu(struct rcu_head *head,
> >>                   void (*func)(struct rcu_head *rcu))
> >>{
> >>     call_rcu(head, func);
> >>}
> >>
> >>tree.c:
> >>
> >>void kfree_call_rcu(struct rcu_head *head,
> >>             void (*func)(struct rcu_head *rcu))
> >>{
> >>     __call_rcu(head, func, rcu_state_p, -1, 1);
> >>}
> >>EXPORT_SYMBOL_GPL(kfree_call_rcu);
> >>
> >>If we want the code to be exactly same I can create a lazy version
> >>for tiny as well. However,  I don not know where to move
> >>kfree_call_rcu() from it's current home in rcutiny.h though. Any
> >>thoughts ?
> >I might be missing something subtle here, but in case I am not, my
> >suggestion is to simply rename rcutiny.h's kfree_call_rcu() and otherwise
> >leave it as is.  If you want to update the type of the second argument,
> >which got missed back in the day, there is always this:
> >
> >static inline void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
> >{
> >	call_rcu(head, func);
> >}
> >
> >The reason that Tiny RCU doesn't handle laziness specially is because
> >Tree RCU's handling of laziness is a big no-op on the single CPU systems
> >on which Tiny RCU runs.  So Tiny RCU need do nothing special to support
> >laziness.
> >
> >							Thanx, Paul
> >
> Hi Paul,
> 
> I can not just change the name as __kfree_call_rcu macro calls
> kfree_call_rcu(). I have made tiny version of kfree_call_rcu() call
> rcu_call_lazy() which calls call_rcu(). As far as the type is
> concerned, my bad, I cut and posted from an older release. Latest
> code is already using the typedef.

Hello, Rao,

Perhaps it would be best if you simply reposted the latest patch.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
