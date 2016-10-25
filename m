Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5476B0271
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:27:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 128so134319135pfz.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 18:27:55 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id qg9si15194210pac.98.2016.10.24.18.27.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 18:27:54 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9P1NPWO065065
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:27:53 -0400
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 269v7wb4aq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 21:27:53 -0400
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 25 Oct 2016 11:27:50 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id ABE932CE805B
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:27:47 +1100 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9P1RlaY64422096
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:27:47 +1100
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9P1RkjF000566
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:27:47 +1100
Subject: Re: [RFC 2/8] mm: Add specialized fallback zonelist for coherent
 device memory nodes
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-3-git-send-email-khandual@linux.vnet.ibm.com>
 <580E406B.4050205@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 25 Oct 2016 06:57:43 +0530
MIME-Version: 1.0
In-Reply-To: <580E406B.4050205@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <580EB50F.3070207@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 10:40 PM, Dave Hansen wrote:
> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +		/*
>> +		 * Isolation requiring coherent device memory node's zones
>> +		 * should not be part of any other node's fallback zonelist
>> +		 * but it's own fallback list.
>> +		 */
>> +		if (isolated_cdm_node(node) && (pgdat->node_id != node))
>> +			continue;
>> +#endif
> 
> Total nit:  Why do you need an #ifdef here when you had
> 
> +#ifdef CONFIG_COHERENT_DEVICE
> +#define node_cdm(nid)          (NODE_DATA(nid)->coherent_device)
> +#define set_cdm_isolation(nid) (node_cdm(nid) = 1)
> +#define clr_cdm_isolation(nid) (node_cdm(nid) = 0)
> +#define isolated_cdm_node(nid) (node_cdm(nid) == 1)
> +#else
> +#define set_cdm_isolation(nid) ()
> +#define clr_cdm_isolation(nid) ()
> +#define isolated_cdm_node(nid) (0)
> +#endif
> 
> in your last patch?

Right, the "if" condition with an "&&" as a whole would have evaluated
to be false. Hence the "ifdef" is not required. Will change it next time
around. Thanks for pointing out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
