Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DB15C4151A
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 10:04:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26247217D6
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 10:04:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26247217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B996A8E001E; Sun,  3 Feb 2019 05:04:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B70F68E001C; Sun,  3 Feb 2019 05:04:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3A5D8E001E; Sun,  3 Feb 2019 05:04:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF198E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 05:04:49 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q81so594052qkl.20
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 02:04:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=HMAMCBwHBJw3ZSzYfnSXTulvBvNLLRrYN1y+iwwM4IY=;
        b=kXCdpf2661DemLXz8heXXVbNLONm8vlczXb9gpMKsp+zcoubje1SqHSDwRNXMD4GDN
         LHWaKwUpj7B7ahLHH6EfzblzQnBKIq2sFidglPt4GEj98tQ3kE30wAtRc22M28cqQuQv
         9ZU920sembYVNTvsGuegQSe2HZLgBsnnTw2EspueC0rYIqtqhmamdjktXoIRGUPfOw2C
         gJkvI4S6IfA/04BAS2wnCsUay6cY7tRVkGf2l3rrDgg0xWw2ofxm2x9Zs8cW16RTZRwg
         iu25b/zmWZnexxvdoLbv0PedH1v9mzL4Yb8ZzDl5YWRhE33QEMhC9z2m0DAXLM3pnFwU
         g0YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukdudVRfezjzj8myrJgNCJ40Wr9LpOL4TA6IhOBX0fxPq4v97NrO
	xS5o5DIVeFArW9/r7hW4mPNkwruYR28JwI8G69UWsh/HWcCwB3JmPXO+D1DgNqWSEH3JzwHm+6V
	5QucK1QagsEFOkT3xO8oya0uzVlh7d54Dphi6GYT0PBzp9dmf7/zZSeRjNFW80CFVmw==
X-Received: by 2002:a37:7481:: with SMTP id p123mr41907501qkc.178.1549188289242;
        Sun, 03 Feb 2019 02:04:49 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Gevkybr0FPNci8i1jzcdNFUHhtZTLDBH+oNYN/eiq3jGdTW8vc850KKD2cGXxKZfrRZJV
X-Received: by 2002:a37:7481:: with SMTP id p123mr41907476qkc.178.1549188288520;
        Sun, 03 Feb 2019 02:04:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549188288; cv=none;
        d=google.com; s=arc-20160816;
        b=yBouR3eZj9XrKbLTMBMPfZU2woh2zNLY89hSLTYpTh3Qd7+oMXAsXfnVY36pjNWUCD
         jdhTkUjBGKOwEp4pZGewjGQSgu48/8vThMIxxxTa3EqMxP2GqDy4aCQgXbpPWFXiJhkZ
         G1+7yVgcHen+Cn8rPByngUmqp4PCmh11H868ZCQJElBhhAVBrorUNQ7eafNHazPwSTjZ
         US8pCq/8j3Ie7jCuk0GCqoiTyYrHexRU4e+FrxelsQDKdA33Ql7EZaXaKbo2hFxehpfE
         lVQo86pQITv+vyjHTwu6ImqI93GKy9/8b/BZFbUaZ+/WiEDGn8KXFCKjtIyPUCGnkwOM
         ALYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=HMAMCBwHBJw3ZSzYfnSXTulvBvNLLRrYN1y+iwwM4IY=;
        b=uN1AAAwUYdXUuAgf+xvYboyGIenyOEApSDbLXCrZpA6GIeL9UBbhyJHSwNYVnn2r4F
         9cqDK0/mh75oRVTnKeI8nnjp/SxWGGQn91KQm9s1y8qR1itqW0MPTuvw9cJvaMy1GBjF
         jDZ6YzqIdYr3JkazBUtwhHtRIb4X9MM/8LmSOmdrKkkMSkbIFiiHQ6zZfGrIthoEQ8YS
         soZjVY0q746BkB+NrzCZSTMj7EIbbY9prlmYqwAAaH9CKuzxkek4yrdxICoa2XZuRMFY
         F4jrIj0zgQmDbsJnnj8uk0xderiYTQ81YMGLefCqnt1d+LlgSZzaIScSmbaXMy8tNlEg
         zGBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v17si3926598qkl.76.2019.02.03.02.04.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 02:04:48 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x13A4f71074110
	for <linux-mm@kvack.org>; Sun, 3 Feb 2019 05:04:48 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qdscugydu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 03 Feb 2019 05:04:47 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 3 Feb 2019 10:04:45 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 3 Feb 2019 10:04:34 -0000
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x13A4XSJ44368088
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Sun, 3 Feb 2019 10:04:33 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7B628A4040;
	Sun,  3 Feb 2019 10:04:33 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5359FA4053;
	Sun,  3 Feb 2019 10:04:30 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun,  3 Feb 2019 10:04:30 +0000 (GMT)
Date: Sun, 3 Feb 2019 12:04:28 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Christoph Hellwig <hch@lst.de>,
        "David S. Miller" <davem@davemloft.net>,
        Dennis Zhou <dennis@kernel.org>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greentime Hu <green.hu@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guan Xuetao <gxt@pku.edu.cn>, Guo Ren <guoren@kernel.org>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Mark Salter <msalter@redhat.com>, Matt Turner <mattst88@gmail.com>,
        Max Filippov <jcmvbkbc@gmail.com>, Michal Simek <monstr@monstr.eu>,
        Paul Burton <paul.burton@mips.com>, Petr Mladek <pmladek@suse.com>,
        Rich Felker <dalias@libc.org>, Richard Weinberger <richard@nod.at>,
        Rob Herring <robh+dt@kernel.org>, Russell King <linux@armlinux.org.uk>,
        Stafford Horne <shorne@gmail.com>, Tony Luck <tony.luck@intel.com>,
        Vineet Gupta <vgupta@synopsys.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        devicetree@vger.kernel.org, kasan-dev@googlegroups.com,
        linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org,
        linux-mips@vger.kernel.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org,
        linux-um@lists.infradead.org, linux-usb@vger.kernel.org,
        linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org,
        openrisc@lists.librecores.org, sparclinux@vger.kernel.org,
        uclinux-h8-devel@lists.sourceforge.jp, x86@kernel.org,
        xen-devel@lists.xenproject.org
Subject: Re: [PATCH v2 10/21] memblock: refactor internal allocation functions
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
 <87ftt5nrcn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ftt5nrcn.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020310-4275-0000-0000-000003097DF6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020310-4276-0000-0000-000038178E51
Message-Id: <20190203100428.GB8620@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-03_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=985 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902030085
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 03, 2019 at 08:39:20PM +1100, Michael Ellerman wrote:
> Mike Rapoport <rppt@linux.ibm.com> writes:
> 
> > Currently, memblock has several internal functions with overlapping
> > functionality. They all call memblock_find_in_range_node() to find free
> > memory and then reserve the allocated range and mark it with kmemleak.
> > However, there is difference in the allocation constraints and in fallback
> > strategies.
> >
> > The allocations returning physical address first attempt to find free
> > memory on the specified node within mirrored memory regions, then retry on
> > the same node without the requirement for memory mirroring and finally fall
> > back to all available memory.
> >
> > The allocations returning virtual address start with clamping the allowed
> > range to memblock.current_limit, attempt to allocate from the specified
> > node from regions with mirroring and with user defined minimal address. If
> > such allocation fails, next attempt is done with node restriction lifted.
> > Next, the allocation is retried with minimal address reset to zero and at
> > last without the requirement for mirrored regions.
> >
> > Let's consolidate various fallbacks handling and make them more consistent
> > for physical and virtual variants. Most of the fallback handling is moved
> > to memblock_alloc_range_nid() and it now handles node and mirror fallbacks.
> >
> > The memblock_alloc_internal() uses memblock_alloc_range_nid() to get a
> > physical address of the allocated range and converts it to virtual address.
> >
> > The fallback for allocation below the specified minimal address remains in
> > memblock_alloc_internal() because memblock_alloc_range_nid() is used by CMA
> > with exact requirement for lower bounds.
> 
> This is causing problems on some of my machines.
> 
> I see NODE_DATA allocations falling back to node 0 when they shouldn't,
> or didn't previously.
> 
> eg, before:
> 
> 57990190: (116011251): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
> 58152042: (116373087): numa:   NODE_DATA [mem 0x8fff90980-0x8fff97fff]
> 
> after:
> 
> 16356872061562: (6296877055): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
> 16356872079279: (6296894772): numa:   NODE_DATA [mem 0xfffcd300-0xfffd497f]
> 16356872096376: (6296911869): numa:     NODE_DATA(1) on node 0
> 
> 
> On some of my other systems it does that, and then panics because it
> can't allocate anything at all:
> 
> [    0.000000] numa:   NODE_DATA [mem 0x7ffcaee80-0x7ffcb3fff]
> [    0.000000] numa:   NODE_DATA [mem 0x7ffc99d00-0x7ffc9ee7f]
> [    0.000000] numa:     NODE_DATA(1) on node 0
> [    0.000000] Kernel panic - not syncing: Cannot allocate 20864 bytes for node 16 data
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc4-gccN-next-20190201-gdc4c899 #1
> [    0.000000] Call Trace:
> [    0.000000] [c0000000011cfca0] [c000000000c11044] dump_stack+0xe8/0x164 (unreliable)
> [    0.000000] [c0000000011cfcf0] [c0000000000fdd6c] panic+0x17c/0x3e0
> [    0.000000] [c0000000011cfd90] [c000000000f61bc8] initmem_init+0x128/0x260
> [    0.000000] [c0000000011cfe60] [c000000000f57940] setup_arch+0x398/0x418
> [    0.000000] [c0000000011cfee0] [c000000000f50a94] start_kernel+0xa0/0x684
> [    0.000000] [c0000000011cff90] [c00000000000af70] start_here_common+0x1c/0x52c
> [    0.000000] Rebooting in 180 seconds..
> 
> 
> So there's something going wrong there, I haven't had time to dig into
> it though (Sunday night here).

I'll try to see if I can reproduce it with qemu.
 
> cheers
> 

-- 
Sincerely yours,
Mike.

