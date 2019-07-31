Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51445C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E88BF206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 17:15:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E88BF206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DEBF8E000A; Wed, 31 Jul 2019 13:15:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88FD68E0001; Wed, 31 Jul 2019 13:15:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7580B8E000A; Wed, 31 Jul 2019 13:15:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 404898E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:15:31 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so43242104pgk.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 10:15:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=QIfxT5RG9GGQYiggevbJ7wQU9KquJ88obAosMLH4YAM=;
        b=n/oTksXl3cQkEBT6sKLcxrzoVlH2VsgnAgpaxthFhBBtnOKzBUDBYxaxXSUjFj5n8Y
         1T83+hLiy6VcNLrggunN0cTbe4Vte9i+vcIhD1lXWs4jQ1XNeuEPXiPtCIdxxubo/FAQ
         ADlw/3Ht1scd4TueOLoOLAp8jDGO1GQLlRCveziJ1HRCPeunxW5X6oRyGgTDKYLvoYFf
         SXxsiUzQqoG60ksoMqWCMZgrBff/iHeUEhUIjrOkXLzIKJIjO7UMNGJYppEMkEYu7kHF
         5DI+kAj/rnNUMt/aAbXdeBg4cCgB/Ijlr11qi1z9k0f2dmR6X3t+Q7ejTz+nzmCbWY0U
         mV0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXijdhLP4IisDZX0p8tmWtSUreOlxc5hWuj5Dn+XmGtGD4OYJT0
	Mr+QbuoaRZgNwL/icEOYlUp6EYN7gtF7vy7amc8qwQkcXySRb9AU7X/hMm7k77lJzihOmwFPZq5
	LeLUazg2gBC05+IP1K3psqxYBOl8WEJqv/f1KgSeJVb+X9BBya0SfeXABSbav7I+1TQ==
X-Received: by 2002:a17:90a:2567:: with SMTP id j94mr3980769pje.121.1564593330921;
        Wed, 31 Jul 2019 10:15:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEVzPcsLylIxN7tMzpyFeTdiLWf6rRtbf+oCgF+7zr7y4RkS28t4tXodjdagcUF1d3ktrz
X-Received: by 2002:a17:90a:2567:: with SMTP id j94mr3980709pje.121.1564593330169;
        Wed, 31 Jul 2019 10:15:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564593330; cv=none;
        d=google.com; s=arc-20160816;
        b=Y/Hq4JdQ1vuqvftZWoAd4MNjujS+BbTRVDY0oMLgk3H1JKVyntkiefT3N2TbZjb2gP
         eKE9PJnTAu2tyulhX9Ch+yMWxtYssKVNW2BnRwN7KbPm8QxOxEYrUpjHXMcZcfW1bCU9
         JH5SswGkO3BwPUQybu5TW51nudAIlXuLkcpYEC3+KcLyBi7fvTXTQMsPAZkS27AlniHd
         Bsj9hvhV46D90Fh1zsQFF+1b7+914dFKbfx59SvZBm3lj9wEdqZrsanPncTd370bnEEx
         62Lrs6USricmuOqFe7khNIPhVKJqwWKpowiIsWj1err2kaWV/KT4pB0K5gccV4wRWtOK
         ePGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=QIfxT5RG9GGQYiggevbJ7wQU9KquJ88obAosMLH4YAM=;
        b=vFEqmNc9vYthvHCNDGDIfR4SeURoSGlNqTT8HAeAZVN9CnMFpf1vbvbXlMoAc3gvDA
         BpUn9shqFZ3kmPNqZm36ZPDzWNklPfFR2LFj4zn+JM3FV7kMBYS5rA5fjDrqiRzuzye/
         4Rx3YmfvPvCmjKTcfzEpEFoKUU7LiQrqsCD6VEPWuVBBp1U6lyTzGuA7LOBqvWX0rCDs
         UMLS81a1/vHRu2qRnVOppdSVFuguBbqIGeF14d21pyVrhhnyHQ2B7l4hgasVbmb+cAUw
         HpEk6J6+fq+Q0sUv1X6JcCntNn/xYqJVPVPlPQkTje6480/dxLIcCZTVuYWAziVjeBq5
         Rerg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c22si29365401plz.361.2019.07.31.10.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 10:15:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6VH7pUL139778
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:15:29 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u3ddd5e41-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:15:29 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 31 Jul 2019 18:15:26 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 31 Jul 2019 18:15:18 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6VHFGw050069666
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 17:15:16 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4E48CAE056;
	Wed, 31 Jul 2019 17:15:16 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 918D8AE04D;
	Wed, 31 Jul 2019 17:15:13 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.240])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 31 Jul 2019 17:15:13 +0000 (GMT)
Date: Wed, 31 Jul 2019 20:15:11 +0300
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
Subject: Re: microblaze HAVE_MEMBLOCK_NODE_MAP dependency (was Re: [PATCH v2
 0/5] mm: Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA)
References: <730368c5-1711-89ae-e3ef-65418b17ddc9@os.amperecomputing.com>
 <20190730081415.GN9330@dhcp22.suse.cz>
 <20190731062420.GC21422@rapoport-lnx>
 <20190731080309.GZ9330@dhcp22.suse.cz>
 <20190731111422.GA14538@rapoport-lnx>
 <20190731114016.GI9330@dhcp22.suse.cz>
 <20190731122631.GB14538@rapoport-lnx>
 <20190731130037.GN9330@dhcp22.suse.cz>
 <20190731142129.GA24998@rapoport-lnx>
 <20190731144114.GY9330@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731144114.GY9330@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19073117-0016-0000-0000-000002980793
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19073117-0017-0000-0000-000032F707ED
Message-Id: <20190731171510.GB24998@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=928 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310172
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 04:41:14PM +0200, Michal Hocko wrote:
> On Wed 31-07-19 17:21:29, Mike Rapoport wrote:
> > On Wed, Jul 31, 2019 at 03:00:37PM +0200, Michal Hocko wrote:
> > > 
> > > I am sorry, but I still do not follow. Who is consuming that node id
> > > information when NUMA=n. In other words why cannot we simply do
> >  
> > We can, I think nobody cared to change it.
> 
> It would be great if somebody with the actual HW could try it out.
> I can throw a patch but I do not even have a cross compiler in my
> toolbox.

Well, it compiles :)
 
> > > diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
> > > index a015a951c8b7..3a47e8db8d1c 100644
> > > --- a/arch/microblaze/mm/init.c
> > > +++ b/arch/microblaze/mm/init.c
> > > @@ -175,14 +175,9 @@ void __init setup_memory(void)
> > >  
> > >  		start_pfn = memblock_region_memory_base_pfn(reg);
> > >  		end_pfn = memblock_region_memory_end_pfn(reg);
> > > -		memblock_set_node(start_pfn << PAGE_SHIFT,
> > > -				  (end_pfn - start_pfn) << PAGE_SHIFT,
> > > -				  &memblock.memory, 0);
> > > +		memory_present(0, start_pfn << PAGE_SHIFT, end_pfn << PAGE_SHIFT);
> > 
> > memory_present() expects pfns, the shift is not needed.
> 
> Right.
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

