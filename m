Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0A96C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:24:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F77D206A3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:24:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F77D206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFCA88E0003; Wed, 31 Jul 2019 02:24:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAC6C8E0001; Wed, 31 Jul 2019 02:24:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C741C8E0003; Wed, 31 Jul 2019 02:24:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A12268E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:24:36 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id w6so51026499ybe.23
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 23:24:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=lTK2l7SPrcnaH+6hC/NaL/v7nuoQBLR8TdALUnoDnwY=;
        b=TA/I2KR9m3ahNNY6Vqfm3B/kx/4OL5A9UrHPWAaYAhDlPPnrVnQZxvDJ0QX9xf8Fb/
         W8OvX6CzpFUGKpsILw6S7QVqbCjdnRUolvs0vX8xrpcK/Bc1LgkK/8hHKlIHJ4GpecP6
         iR36NvM+xL2cGx1zwU/Dq50xSTzNUbkzY12f9IOfFguX3Ul31/HXCqRXp3seiYWnE1Dd
         cdPduLjt60BnBtNzf/3F5cRGnl9ZWMJtYonndFVCJPszdvrv1XjheV5TGZXQ/LuoFG01
         F2GF5Z3TaEaucPosmG5Hey3aPaR4ngkAcwxGfW4dkcbbxh5XR2aXGnTeWayG2yRBVkwZ
         rZ0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAV/bSF0Q3mnVCARQzSYShRJLuCd3Afxs5k0eHLBQGx1yTfPjnbL
	L/iw0ZpPMyyZb33oGZHo/yxDu2bDcWqQyt3b7e3HwsuTPzTLRr6X/cRS0yXL/O/SyD+kwa/kdJP
	k9yaguKtk6NLVvA6hmoce06YfgiWWUN6hpYMDDqRg9T89Z+FNk+sn5epgfQoN6+iZMQ==
X-Received: by 2002:a81:6d8a:: with SMTP id i132mr71106340ywc.304.1564554276331;
        Tue, 30 Jul 2019 23:24:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvjqyy2vtohG2P9YOj+O8i4LnUHLoh+tHJ3Tx1UFFLUATC7VVjybhvqbBls2oZ6r1k1mck
X-Received: by 2002:a81:6d8a:: with SMTP id i132mr71106328ywc.304.1564554275708;
        Tue, 30 Jul 2019 23:24:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564554275; cv=none;
        d=google.com; s=arc-20160816;
        b=WVExK3vQnPlpL5YqFGHf+iagYicWZm3V4aiiv+vkOCusuivTGn4rcUSHNLJUWAnA1A
         L9CMzIWY7t2sc/X0+B98im5fCjs5hsR0wd56KB6xKiKv4I3h78DvMCJf3wUk0fnCfiDv
         4RW9YJvH90SRzDhxQjLd8h+wpCIH33j3196h3xCt4QrMuF1EnvxWPQBAdrgA2QbogBjf
         6bXZofVmtDScxT+etRFRpJv/l8mAOR6It3pd/nIyQiLikMbG7Q/Q3pOmWSn4LQgCLXUf
         DDtNT51z0SwCBNfbI0cpcaalNyJgzFQQuZ3TRCzVEadZoaHYVnGf6R27KkZ+GhEiCbEJ
         XK9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=lTK2l7SPrcnaH+6hC/NaL/v7nuoQBLR8TdALUnoDnwY=;
        b=eLQ0EQfKS3Ix10J9v2BVrdBDxwbw5ZdNcF0mCBObNlls8bymRKaKEPQgozFdsPXAYA
         jwH0YmondvD6Zr6THZiE0TuHImSM4EuxUfcPMw3VkhgSvDqO2Mzh/2UlAjbkIlyrmbr9
         PbJbuOXTbDTwyj+6991cVxYz6zoGl1xz2OqR9LZorbw6EM/cobrm9QM/XhesMPYWGLkR
         zfIWL6PGXAcHxbRIowhe25mNBGNfneSStqBSiz4QgH/0E1IqkseNc71CVLAZt+Wbt7sf
         bIZTCKnFN9xsO6uk14wpIaxnxSy2sCW6/o+gHLH0NytEE9j4YTZrS3CpoPacTJLJotWi
         uhfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n130si1332271ybn.452.2019.07.30.23.24.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 23:24:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6V6NQJH103277
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:24:35 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u33fkvxam-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:24:35 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 31 Jul 2019 07:24:33 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 07:24:26 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6V6OOGr54919308
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 06:24:24 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B099C11C058;
	Wed, 31 Jul 2019 06:24:24 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AA3CE11C04C;
	Wed, 31 Jul 2019 06:24:22 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 31 Jul 2019 06:24:22 +0000 (GMT)
Date: Wed, 31 Jul 2019 09:24:21 +0300
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
References: <1562887528-5896-1-git-send-email-Hoan@os.amperecomputing.com>
 <20190712070247.GM29483@dhcp22.suse.cz>
 <586ae736-a429-cf94-1520-1a94ffadad88@os.amperecomputing.com>
 <20190712121223.GR29483@dhcp22.suse.cz>
 <20190712143730.au3662g4ua2tjudu@willie-the-truck>
 <20190712150007.GU29483@dhcp22.suse.cz>
 <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730081415.GN9330@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19073106-0008-0000-0000-000003027A16
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073106-0009-0000-0000-000022701E30
Message-Id: <20190731062420.GC21422@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=758 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310066
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ sorry for a late reply too, somehow I missed this thread before ]

On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> [Sorry for a late reply]
> 
> On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > Hi,
> > 
> > On 7/12/19 10:00 PM, Michal Hocko wrote:
> [...]
> > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > Looking more closely, it seems that this is indeed only about
> > > __early_pfn_to_nid and as such not something that should add a config
> > > symbol. This should have been called out in the changelog though.
> > 
> > Yes, do you have any other comments about my patch?
> 
> Not really. Just make sure to explicitly state that
> CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> doesn't really deserve it's own config and can be pulled under NUMA.
> 
> > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > 

HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
sequence so it's not only about a singe function.

> > As I checked with arch Kconfig files, there are 2 architectures, riscv 
> > and microblaze, do not support NUMA but enable this config.

My take would be that riscv will support NUMA some day.
 
> > And 1 architecture, alpha, supports NUMA but does not enable this config.

alpha's NUMA support is BROKEN for more than a decade now, I doubt it'll
ever get fixed.
 
> Care to have a look and clean this up please?
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

