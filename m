Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82CFCC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:26:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 413DB208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 12:26:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 413DB208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFE678E0009; Wed, 31 Jul 2019 08:26:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAD4C8E0001; Wed, 31 Jul 2019 08:26:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9D788E0009; Wed, 31 Jul 2019 08:26:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A87908E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:26:48 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id s17so12189104ybg.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 05:26:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=Msp32Hew4Bx+pZ9ih09OVDivmI04xZYLkcehNlFACf8=;
        b=t5o39aimiykRvaBo23825nprLQTOQFZqD44HyjkxusenyZO1mrGe1B7hXjQ/0x9viW
         AKIWg8jq5PINUX6oBnWd2pdkO/Y6NY/KpDpcNi0zcC1CkEzE//WAWulzL5U4/Q3dpO2e
         ZU1su7eatUF4kuWdn4sbWeIzWMZF2FRZBGW+KIU74NR16YbZfmUpVOxd7nrytQHc+gX2
         2PxnwB920ML/nhZGEoT8cA0mxRj1SSRc2bDAAZyLskD6Ibt4VqLZkx3IjeCPPbXcw/ww
         Ep2msS/8zpbZ+T9KjM0ThXWBQZmUqk3ZwNnUorjYVyTMNtXaHPPqEuTminZ97iXi3aaV
         +cZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX4h5Ok1T2mJWVJITS1J3NntVUjVWXewFnhV73Z0ihzvBbTWfA9
	zg72RlnHy5nIVRHjokKeMCGW7z5N5esSKj3XmrfFSGquicmr/VNiLtRo8J+0Nyya3yE6/4Z2B0R
	/c/4T2vzqvd8MYtcOiKSPOiPVRLBf+1MmhKXmNYm7LH39HuEBwviick8ncoz35jVT2g==
X-Received: by 2002:a81:79d2:: with SMTP id u201mr70386947ywc.457.1564576008448;
        Wed, 31 Jul 2019 05:26:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQ0hYcFpOqEA4Hy5rBxGB1DT0d5Z5YCC/JM8IFTBUDOvo4TAhkOWt4DZ3Je4wVuzFhIqlb
X-Received: by 2002:a81:79d2:: with SMTP id u201mr70386915ywc.457.1564576007808;
        Wed, 31 Jul 2019 05:26:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564576007; cv=none;
        d=google.com; s=arc-20160816;
        b=YxcdRe/Qwsyv7y02OpkbKsSXQfz6xNeBhIAMkH377T/SiRvDLdTjA6x8+RmHcNOJFg
         rOsdBLXmWhQ95pzEzhkIce9oNx9cdP3nCqIF98wJB0sUFnD8MtLYI2j+wJCp67sFu36L
         93psCYCH+Bk7pmrG9a+Lr/NnqUPhoVlA6DtcgOt6mS/fP38EW3hziYgbokg5dL3P4CFK
         qL6gK9R8E6iBrfP0DxXohGxYoyf9RxEGOJBM600WRyCZkbgDmLKNM8QgWkTcnUewEToE
         JNo/ONdHpjIuyBRrSR3bHBRqsnL13TDwwk+vnRXOsXAu2PRCYsrcX4Qfe6OMnzGy3FdL
         9D9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=Msp32Hew4Bx+pZ9ih09OVDivmI04xZYLkcehNlFACf8=;
        b=q3pC0BIOPQdpg321x52DmFzg8Blz72lBOyGoTIHPLVC/gqYpPbO0nrZHf3lNYIail+
         IshqMb0RB9fqTJ8sSeFTeY1jYlwRWRhiKf/ZbmKzqakueU+WXf14/Wo7PYDq82aBFGaT
         4y/V4M+ORK/ywvvYeEpMn5drpcrcdhfnCtvRzFt5aWrZ1/jQl5xGoGQ4uoUljfStBcIA
         ibRPufnop+jcRDpp24kXxqd8hctYT9obCSc+ZW7k7al+jHcRYJOnJuPCOESedNbzvLm+
         67SBF0fKzAbNv+8O4/JX9GlH3rUDZxefxkoZZXSdDl4cLkvzJF7sU1Co8s862RfvQFxS
         JIyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p204si23385296ywg.426.2019.07.31.05.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 05:26:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6VCNDLP074057
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:26:47 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2u38f27jh2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:26:47 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 31 Jul 2019 13:26:45 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 13:26:37 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6VCQZF059244618
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 12:26:36 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id DB81511C05B;
	Wed, 31 Jul 2019 12:26:35 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D43D911C04A;
	Wed, 31 Jul 2019 12:26:33 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 31 Jul 2019 12:26:33 +0000 (GMT)
Date: Wed, 31 Jul 2019 15:26:32 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hoan Tran OS <hoan@os.amperecomputing.com>, Will Deacon <will@kernel.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>,
        Paul Mackerras <paulus@samba.org>, "H . Peter Anvin" <hpa@zytor.com>,
        "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        "x86@kernel.org" <x86@kernel.org>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Open Source Submission <patches@amperecomputing.com>,
        Pavel Tatashin <pavel.tatashin@microsoft.com>,
        Vasily Gorbik <gor@linux.ibm.com>, Will Deacon <will.deacon@arm.com>,
        Borislav Petkov <bp@alien8.de>, Thomas Gleixner <tglx@linutronix.de>,
        "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
        Oscar Salvador <osalvador@suse.de>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "David S . Miller" <davem@davemloft.net>,
        "willy@infradead.org" <willy@infradead.org>
Subject: Re: [PATCH v2 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by
 default for NUMA
References: <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731114016.GI9330@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19073112-0028-0000-0000-00000389A2B7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073112-0029-0000-0000-00002449F381
Message-Id: <20190731122631.GB14538@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=757 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310126
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 01:40:16PM +0200, Michal Hocko wrote:
> On Wed 31-07-19 14:14:22, Mike Rapoport wrote:
> > On Wed, Jul 31, 2019 at 10:03:09AM +0200, Michal Hocko wrote:
> > > On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> > > > [ sorry for a late reply too, somehow I missed this thread before ]
> > > > 
> > > > On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > > > > [Sorry for a late reply]
> > > > > 
> > > > > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > > > > Hi,
> > > > > > 
> > > > > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > > > > [...]
> > > > > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > > > > Looking more closely, it seems that this is indeed only about
> > > > > > > __early_pfn_to_nid and as such not something that should add a config
> > > > > > > symbol. This should have been called out in the changelog though.
> > > > > > 
> > > > > > Yes, do you have any other comments about my patch?
> > > > > 
> > > > > Not really. Just make sure to explicitly state that
> > > > > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > > > > doesn't really deserve it's own config and can be pulled under NUMA.
> > > > > 
> > > > > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > > > > 
> > > > 
> > > > HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> > > > sequence so it's not only about a singe function.
> > > 
> > > The question is whether we want to have this a config option or enable
> > > it unconditionally for each NUMA system.
> > 
> > We can make it 'default NUMA', but we can't drop it completely because
> > microblaze uses sparse_memory_present_with_active_regions() which is
> > unavailable when HAVE_MEMBLOCK_NODE_MAP=n.
> 
> I suppose you mean that microblaze is using
> sparse_memory_present_with_active_regions even without CONFIG_NUMA,
> right?

Yes.

> I have to confess I do not understand that code. What is the deal
> with setting node id there?

The sparse_memory_present_with_active_regions() iterates over
memblock.memory regions and uses the node id of each region as the
parameter to memory_present(). The assumption here is that sometime before
each region was assigned a proper non-negative node id. 

microblaze uses device tree for memory enumeration and the current FDT code
does memblock_add() that implicitly sets nid in memblock.memory regions to -1.

So in order to have proper node id passed to memory_present() microblaze
has to call memblock_set_node() before it can use
sparse_memory_present_with_active_regions().

> -- 
> Michal Hocko
> SUSE Labs

-- 
Sincerely yours,
Mike.

