Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id A3BDC6B6C56
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 03:37:26 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p14-v6so3261147oip.0
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 00:37:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k64-v6si14159338oih.154.2018.09.04.00.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 00:37:25 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w847XwWx104920
	for <linux-mm@kvack.org>; Tue, 4 Sep 2018 03:37:25 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m9m9tv09f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Sep 2018 03:37:25 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 4 Sep 2018 08:37:23 +0100
Date: Tue, 4 Sep 2018 10:37:18 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] userfaultfd: allow
 get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) to trigger userfaults
References: <20180831214848.23676-1-aarcange@redhat.com>
 <20180903163312.4d758536e1208f8927d886e9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180903163312.4d758536e1208f8927d886e9@linux-foundation.org>
Message-Id: <20180904073718.GA26916@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Maxime Coquelin <maxime.coquelin@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Sep 03, 2018 at 04:33:12PM -0700, Andrew Morton wrote:
> On Fri, 31 Aug 2018 17:48:48 -0400 Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) called a get_user_pages that
> > would not be waiting for userfaults before failing and it would hit on
> > a SIGBUS instead. Using get_user_pages_locked/unlocked instead will
> > allow get_mempolicy to allow userfaults to resolve the fault and fill
> > the hole, before grabbing the node id of the page.
> 
> What is the userspace visible impact of this change?
> 

If the user calls get_mempolicy() with MPOL_F_ADDR | MPOL_F_NODE for an
address inside an area managed by uffd and there is no page at that
address, the page allocation from within get_mempolicy() will fail because
get_user_pages() does not allow for page fault retry required for uffd; the
user will get SIGBUS.

With this patch, the page fault will be resolved by the uffd and the
get_mempolicy() will continue normally.

-- 
Sincerely yours,
Mike.
