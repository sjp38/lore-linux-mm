Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD0E46B0038
	for <linux-mm@kvack.org>; Wed,  3 May 2017 03:23:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i25so8110635pfa.23
        for <linux-mm@kvack.org>; Wed, 03 May 2017 00:23:41 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g6si19939517pgc.36.2017.05.03.00.23.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 May 2017 00:23:41 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v437IhU1134374
	for <linux-mm@kvack.org>; Wed, 3 May 2017 03:23:40 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2a7aass276-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 May 2017 03:23:40 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 3 May 2017 08:23:37 +0100
Subject: Re: [RFC v3 05/17] RCU free VMAs
References: <1493308376-23851-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1493308376-23851-6-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170430050529.GH27790@bombadil.infradead.org>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 3 May 2017 09:23:31 +0200
MIME-Version: 1.0
In-Reply-To: <20170430050529.GH27790@bombadil.infradead.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <be153da3-fc43-a70e-ff15-8c57d727f2f3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 30/04/2017 07:05, Matthew Wilcox wrote:
> On Thu, Apr 27, 2017 at 05:52:44PM +0200, Laurent Dufour wrote:
>> +static inline bool vma_is_dead(struct vm_area_struct *vma, unsigned int sequence)
>> +{
>> +	int ret = RB_EMPTY_NODE(&vma->vm_rb);
>> +	unsigned seq = ACCESS_ONCE(vma->vm_sequence.sequence);
>> +
>> +	/*
>> +	 * Matches both the wmb in write_seqlock_{begin,end}() and
>> +	 * the wmb in vma_rb_erase().
>> +	 */
>> +	smp_rmb();
>> +
>> +	return ret || seq != sequence;
>> +}
> 
> Hang on, this isn't vma_is_dead().  This is vma_has_changed() (possibly
> from live to dead, but also possibly grown or shrunk; see your earlier
> patch).

This makes sense.

Thanks,
Laurent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
