Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06BBE6B0038
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:22:27 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id d9so452611qkg.13
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 12:22:27 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i190si182159qkf.377.2017.12.19.12.22.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 12:22:25 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBJKDwWa112790
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:22:25 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ey4cksju0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 15:22:25 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 19 Dec 2017 15:22:24 -0500
Date: Tue, 19 Dec 2017 12:22:32 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Reply-To: paulmck@linux.vnet.ibm.com
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219193039.GB6515@bombadil.infradead.org>
 <24c9f1c0-58d4-5d27-8795-d211693455dd@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <24c9f1c0-58d4-5d27-8795-d211693455dd@oracle.com>
Message-Id: <20171219202232.GE7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 11:56:30AM -0800, Rao Shoaib wrote:
> On 12/19/2017 11:30 AM, Matthew Wilcox wrote:
> >On Tue, Dec 19, 2017 at 09:52:27AM -0800, rao.shoaib@oracle.com wrote:

[ . . . ]

> >I've been doing a lot of thinking about this because I really want a
> >way to kfree_rcu() an object without embedding a struct rcu_head in it.
> >But I see no way to do that today; even if we have an external memory
> >allocation to point to the object to be freed, we have to keep track of
> >the grace periods.
> I am not sure I understand. If you had external memory you can
> easily do that.
> I am exactly doing that, the only reason the RCU structure is needed
> is to get the pointer to the object being freed.

This can be done as long as you are willing to either:

1.	Occasionally have kfree_rcu() wait for a grace period.

2.	Occasionally have kfree_rcu() allocate memory.

3.	Keep the rcu_head, but use it only when you would otherwise
	have to accept the above two penalties.  (The point of this
	is that tracking lists of memory waiting for a grace period
	using dense arrays improves cache locality.)

There might be others, and if you come up with one, please don't keep it
a secret.  The C++ standards committee insisted on an interface using
option #2 above.  (There is also an option to use their equivalent of
an rcu_head.)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
