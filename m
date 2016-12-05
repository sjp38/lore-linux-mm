Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E06526B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 09:09:41 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so508960024pfx.1
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 06:09:41 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l2si14738063pgo.298.2016.12.05.06.09.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 06:09:40 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB5E9DmK135082
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 09:09:40 -0500
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2753yducjv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Dec 2016 09:09:40 -0500
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 5 Dec 2016 14:09:38 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 3B8B02190066
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 14:08:46 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uB5E9ZPT6095122
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 14:09:35 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uB5E9YqY025032
	for <linux-mm@kvack.org>; Mon, 5 Dec 2016 09:09:35 -0500
Date: Mon, 5 Dec 2016 15:09:33 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm: use vmalloc fallback path for certain memcg
 allocations
References: <1480554981-195198-1-git-send-email-astepanov@cloudlinux.com>
 <03a17767-1322-3466-a1f1-dba2c6862be4@suse.cz>
 <20161202091933.GD6830@dhcp22.suse.cz>
 <20161202065417.GB358195@stepanov.centos7>
 <20161205052325.GA30758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161205052325.GA30758@dhcp22.suse.cz>
Message-Id: <20161205140932.GC8045@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Anatoly Stepanov <astepanov@cloudlinux.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com, umka@cloudlinux.com, panda@cloudlinux.com, vmeshkov@cloudlinux.com

On Mon, Dec 05, 2016 at 06:23:26AM +0100, Michal Hocko wrote:
> > > 
> > > 	ret = kzalloc(size, gfp_mask);
> > > 	if (ret)
> > > 		return ret;
> > > 	return vzalloc(size);
> > > 
> > 
> > > I also do not like memcg_alloc helper name. It suggests we are
> > > allocating a memcg while it is used for cache arrays and slab LRUS.
> > > Anyway this pattern is quite widespread in the kernel so I would simply
> > > suggest adding kvmalloc function instead.
> > 
> > Agreed, it would be nice to have a generic call.
> > I would suggest an impl. like this:
> > 
> > void *kvmalloc(size_t size)
> 
> gfp_t gfp_mask should be a parameter as this should be a generic helper.
> 
> > {
> > 	gfp_t gfp_mask = GFP_KERNEL;
> 
> 
> > 	void *ret;
> > 
> >  	if (size > PAGE_SIZE)
> >  		gfp_mask |= __GFP_NORETRY | __GFP_NOWARN;
> > 
> > 
> > 	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> > 		ret = kzalloc(size, gfp_mask);
> > 		if (ret)
> > 			return ret;
> > 	}
> 
> No, please just do as suggested above. Tweak the gfp_mask for higher
> order requests and do kmalloc first with vmalloc as a  fallback.

You may simply use the slightly different and open-coded variant within
fs/seq_file.c:seq_buf_alloc(). That one got a lot of testing in the
meantime...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
