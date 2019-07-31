Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4966BC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A2A2206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 11:14:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A2A2206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9520F8E0003; Wed, 31 Jul 2019 07:14:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 929C48E0001; Wed, 31 Jul 2019 07:14:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8192C8E0003; Wed, 31 Jul 2019 07:14:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8408E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:14:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q9so42594195pgv.17
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:14:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=SwIk45OC9oaBn7emooR3EnqJ0iY1na1ShEftoFfwG7c=;
        b=e89x7PF3R5jqcahlRANfLpqRKG94Mph59W/CXSp98ZbR2VNi1fweIJbZghJeixEIzD
         kd1Iw0gFOmPBK5stELwctCls6tnBe+HdBKeSSQws03mt6DJF9NCR0iqdkJGKT0ryA+t+
         b8SAOI+pPLqPKvLI8PtApkTufSFSMkRs9C5qIoi05oQI7nuTljnG8eXFgOEnrsBU8Rl5
         MpUM3llGe1SzvZGcHLGivvzgpHk/A9UEbUjvO78rLcU6mow7499Mprw09+si1Ho0MkMM
         Psq0yv5BdY+m0dyA+9eDVK5lnPYsWMBK859iGyxYzxUa6oKPhjic9qru71dIKidnmOq3
         2pPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXD+RX7E8GCq+YXyQWZi8fp9hZer79s5nLtnDvci45oBT9dEyl0
	fT2avB6L84zyQx+edGeRE68i6VKwAyEuO23QKd+yZAR/fFUx3Ib6+B55zbjUsNvId/JkjYoo8mT
	8cMrF2vUOtoON+Sb7PfZPf3a/2xoOB3O23dG5XGiEhmyZ0CHH2PABnw6g8X+hVKphng==
X-Received: by 2002:a65:5348:: with SMTP id w8mr112425042pgr.176.1564571680849;
        Wed, 31 Jul 2019 04:14:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztvcda7Y643pc/Grr6wQKScMQOIcDIChF9ZkcZ+5i/bX9yeq3p82AoSDGeg59afbjDi2BL
X-Received: by 2002:a65:5348:: with SMTP id w8mr112424983pgr.176.1564571680003;
        Wed, 31 Jul 2019 04:14:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564571680; cv=none;
        d=google.com; s=arc-20160816;
        b=E2DBHevoczixGaabIb6HdkuKUyGu1mI2diJxarrI1ZKizGhNNm5Ybt1NqP9Xvb44dT
         RvyHc9rQIh5SBIh5VLOce191d5O6APbEXwIV1voQgzBQ829DE8WPPjlbtiEOwwPlcR04
         K+hPU7tQnpzLb5fqHiDXJNastRjeOy94pJhvvTE/eEkrsuRHh3LqvGKiSjKD+wKpjVec
         Ai7nAHJ+fc1pp7vgZDY/OpdjH+/T65yJldhcqjDyclM32nmo8oVr4oyqJ2h3jNpltvhL
         lmFSEiX3iOw3aXZVfRb28LfSfsa3v4LBqDb00W1IBOcjgmBy0sBMXGwTPLuKGOHlHq/Q
         oUxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=SwIk45OC9oaBn7emooR3EnqJ0iY1na1ShEftoFfwG7c=;
        b=ujsOh9/aooSh8ccSguHMtfUDEi3HLGOb+wt+Nt/YN4kPgW4mMKtE9pTxJ7CgTvZJVy
         QmQohEMvM1TWrs8/4y2RYfeQ2ByDXIoeX1bBfc2TOSbYcKmYaBaU3GI6P8NAsS6d1qyd
         X0TWKmO/GzA7OMvTiyoe3K/mvo1+AIimdrRUPVW6eWH71L+7d1ql5ntXFlWfEFHfHXy/
         W24uv3HAV3wVj/Vm3QVEz5QsvkBH4qmIdcrJrvQwrfCDZ9sjhDkx5o6biKzXnsLBzlVI
         4UiOL5YdZj6pttwww1WXfcxL8u+9XTk0f9PmlKyKO7hrW2MqTsfqTa81+1V9DIVIouFR
         18HA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id q38si17922090pgk.63.2019.07.31.04.14.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 04:14:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6VBCnub036648
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:14:39 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u39krrxhx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 07:14:39 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 31 Jul 2019 12:14:36 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 12:14:28 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6VBEQfn26607736
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 11:14:26 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A5DCA4C050;
	Wed, 31 Jul 2019 11:14:26 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 897844C044;
	Wed, 31 Jul 2019 11:14:24 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 31 Jul 2019 11:14:24 +0000 (GMT)
Date: Wed, 31 Jul 2019 14:14:22 +0300
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
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731080309.GZ9330@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19073111-0020-0000-0000-00000358F06A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073111-0021-0000-0000-000021ACF9B2
Message-Id: <20190731111422.GA14538@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=627 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310117
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 10:03:09AM +0200, Michal Hocko wrote:
> On Wed 31-07-19 09:24:21, Mike Rapoport wrote:
> > [ sorry for a late reply too, somehow I missed this thread before ]
> > 
> > On Tue, Jul 30, 2019 at 10:14:15AM +0200, Michal Hocko wrote:
> > > [Sorry for a late reply]
> > > 
> > > On Mon 15-07-19 17:55:07, Hoan Tran OS wrote:
> > > > Hi,
> > > > 
> > > > On 7/12/19 10:00 PM, Michal Hocko wrote:
> > > [...]
> > > > > Hmm, I thought this was selectable. But I am obviously wrong here.
> > > > > Looking more closely, it seems that this is indeed only about
> > > > > __early_pfn_to_nid and as such not something that should add a config
> > > > > symbol. This should have been called out in the changelog though.
> > > > 
> > > > Yes, do you have any other comments about my patch?
> > > 
> > > Not really. Just make sure to explicitly state that
> > > CONFIG_NODES_SPAN_OTHER_NODES is only about __early_pfn_to_nid and that
> > > doesn't really deserve it's own config and can be pulled under NUMA.
> > > 
> > > > > Also while at it, does HAVE_MEMBLOCK_NODE_MAP fall into a similar
> > > > > bucket? Do we have any NUMA architecture that doesn't enable it?
> > > > > 
> > 
> > HAVE_MEMBLOCK_NODE_MAP makes huge difference in node/zone initialization
> > sequence so it's not only about a singe function.
> 
> The question is whether we want to have this a config option or enable
> it unconditionally for each NUMA system.

We can make it 'default NUMA', but we can't drop it completely because
microblaze uses sparse_memory_present_with_active_regions() which is
unavailable when HAVE_MEMBLOCK_NODE_MAP=n.

> > > > As I checked with arch Kconfig files, there are 2 architectures, riscv 
> > > > and microblaze, do not support NUMA but enable this config.
> > 
> > My take would be that riscv will support NUMA some day.
> >  
> > > > And 1 architecture, alpha, supports NUMA but does not enable this config.
> > 
> > alpha's NUMA support is BROKEN for more than a decade now, I doubt it'll
> > ever get fixed.
> 
> I can see Al has marked it BROKEN in 2005. Maybe time to rip it out?
> Although it doesn't seem to be a lot of code in arch/alpha at first
> glance so maybe not worth an effort.
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

