Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 406E6C31E5D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:37:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 024482082C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 21:37:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lljcPfBp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 024482082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 917126B0005; Mon, 17 Jun 2019 17:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C8CE8E0002; Mon, 17 Jun 2019 17:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B6B18E0001; Mon, 17 Jun 2019 17:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BD9D6B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:37:50 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id m26so13610156ioh.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:37:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=GOIdRAMf3skF4wPK2T/7fFj0vhfi1GT6kR2ybYgOAu4=;
        b=g9bBEzKBB8GfNUXs2TyIRL1viN4IbKg1hj1OTV/GmNzOW/1EVPDIP3BOamOFof6mcf
         9ckMGMYkkCVV7+zmrDbd5OVDOu0H2Q6cN6qrlNFOf8ClQV2xSyWa8ZDklTG0v2/MV224
         PMCZB2W/BZ7zItCvNQPLNHL1HwgYF7FZl34iMWDeRQ2oRAHySwfuBuuXF7urSZUa4YYf
         0BGQSVuSJYKBHEMxFfSLVNFQUf8SnEDFeDwYvMUH9HpiIU1ZHHx87ulXtIVzt0YVfsgv
         QCfNYqZp11vrSR+9BUmreFTDBCYhh8Kc1ByCc99HdFD6iDpg/qGAq5Tv0bj6t6xv/YPh
         pUsQ==
X-Gm-Message-State: APjAAAXYpNVl1qnfQO8zQW1UOM1v0JxBF9KXd7oofMsNVRIJ3K3AKutO
	sGCvh94YPbdaCxf7cbDA4GLCcIxHwd333hApidl8N1k/XtV18KaHQLMItvIYX9Z0FqeDfNfEf8C
	xJA1h9NQ8AmZBWvIF2mF9BF2FmVEZRWWbU+dQNQWSR1qQO3lWhlrLXobtZ1XSJ8bq1w==
X-Received: by 2002:a05:6638:605:: with SMTP id g5mr3484jar.110.1560807470077;
        Mon, 17 Jun 2019 14:37:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1RrNrJfIXp38RwMGkfBYEWdlBj56nqI23fMvaVikuGVKZdYSjFBxFyWJ6r/sQRXYpneBR
X-Received: by 2002:a05:6638:605:: with SMTP id g5mr963457jar.110.1560797080465;
        Mon, 17 Jun 2019 11:44:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560797080; cv=none;
        d=google.com; s=arc-20160816;
        b=LVOG8otoCTh8ayeeDxYEE42FRgBBUY5LnuSJDFKokRcE8zvDHTonkaTRLxJ7IiJFS1
         Rv0vTx4J97HYqqvRus4BLYez9+OBRmuJSe6B3jf2C/i+GPFk6IHujP7xQffprEu2h5MC
         IZ890ZG8e4yIhM3wefJPnx4JeB2FOgquDhL2h4ol8U6aNtd0jxwy1jNRNxDXurOniF26
         SJQU8DVNWlTBVNFfWrqrZ810IO/Zm9/bCPM7KrDISZm2BMBFBC/hWhET76QOzp+paJ5C
         r/Th6JZFb8n+p0IkocvjqtQzCr86280Tcm54zJFstugGglqMDh8GJQKCSDimSe+ZDllG
         KFhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=GOIdRAMf3skF4wPK2T/7fFj0vhfi1GT6kR2ybYgOAu4=;
        b=VZtky4jpk7pcfOI5pzkPeFx+eHSg+aWw5m+tuR3Pu5F66Y/nObZCQ2DFo5GdE0j9M+
         LixJGnKQ+guBab5R8/Bdo9r/xWpiy2oIQIxMgLZb2LBbBamEWyCObNBPdFNfcO6DknYr
         vE1vSAhAcrHJsAUEeMpWVJmO1Nh0TCbedaABYpyBzvnSp9GljEvmDWMrrVT0ukRvm2xU
         dFKdlVAih95bVa78126QP7aameNVHCUEHgbKFkb7n32ix4s0MAl0m2PJHI3WOrivc5X8
         Snmx4q/pfBMoP7Mfo3vz0YzdSUn8ig20hEDwVM1w8eTU6VUVSwQHcGUl/9wmxnJLIl34
         jVXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lljcPfBp;
       spf=pass (google.com: domain of konrad.wilk@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=konrad.wilk@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k17si15057532iok.52.2019.06.17.11.44.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 11:44:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of konrad.wilk@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=lljcPfBp;
       spf=pass (google.com: domain of konrad.wilk@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=konrad.wilk@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5HIhvF7186461;
	Mon, 17 Jun 2019 18:44:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=GOIdRAMf3skF4wPK2T/7fFj0vhfi1GT6kR2ybYgOAu4=;
 b=lljcPfBpWWXCHaf1yRMmXyfI54fHwvCFKfK5VIao6y/jBGDnvk52ml8ocSTuVDbgc2QO
 aKpxdSEeWRAAE+4oDoqRrIrhX+jfnrFlj7QNLaYUL0F/6MzY/SzEzmD1f6vEiHByXW49
 VI5gQ1ROqihrvrj4+AK0i3Ww+1kYqFVi58GQ0JM//3tp5uKq7RYNjAPJf5QPQ90/6ssZ
 kh8E6dIhQMuR1uTOnbVXsoqrYQL40V88lnlUVGONOr9O9ZVkcJjKoy+5QYdfAgjFfDej
 Jv53Hqeo8nSxxDhrbBtZbtWsG6GEfXzg37XQNCJA9pfhAEwU7SeLpbHIik7nMCKfnIBS xg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2t4saq83g6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 18:44:19 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5HIhXeI066471;
	Mon, 17 Jun 2019 18:44:19 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2t59gdcub9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 17 Jun 2019 18:44:19 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x5HIiDdo015527;
	Mon, 17 Jun 2019 18:44:14 GMT
Received: from char.us.oracle.com (/10.152.32.25)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 17 Jun 2019 11:44:12 -0700
Received: by char.us.oracle.com (Postfix, from userid 1000)
	id DF1D76A0120; Mon, 17 Jun 2019 14:45:36 -0400 (EDT)
Date: Mon, 17 Jun 2019 14:45:36 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Nadav Amit <nadav.amit@gmail.com>, Andy Lutomirski <luto@kernel.org>,
        Alexander Graf <graf@amazon.com>, Thomas Gleixner <tglx@linutronix.de>,
        Marius Hillenbrand <mhillenb@amazon.de>,
        kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
        Kernel Hardening <kernel-hardening@lists.openwall.com>,
        Linux-MM <linux-mm@kvack.org>, Alexander Graf <graf@amazon.de>,
        David Woodhouse <dwmw@amazon.co.uk>,
        the arch/x86 maintainers <x86@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
Message-ID: <20190617184536.GB11017@char.us.oracle.com>
References: <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com>
 <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
 <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
 <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
 <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com>
 <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9291 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906170165
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9291 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906170166
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 11:07:45AM -0700, Dave Hansen wrote:
> On 6/17/19 9:53 AM, Nadav Amit wrote:
> >>> For anyone following along at home, I'm going to go off into crazy
> >>> per-cpu-pgds speculation mode now...  Feel free to stop reading now. :)
> >>>
> >>> But, I was thinking we could get away with not doing this on _every_
> >>> context switch at least.  For instance, couldn't 'struct tlb_context'
> >>> have PGD pointer (or two with PTI) in addition to the TLB info?  That
> >>> way we only do the copying when we change the context.  Or does that tie
> >>> the implementation up too much with PCIDs?
> >> Hmm, that seems entirely reasonable.  I think the nasty bit would be
> >> figuring out all the interactions with PV TLB flushing.  PV TLB
> >> flushes already don't play so well with PCID tracking, and this will
> >> make it worse.  We probably need to rewrite all that code regardless.
> > How is PCID (as you implemented) related to TLB flushing of kernel (not
> > user) PTEs? These kernel PTEs would be global, so they would be invalidated
> > from all the address-spaces using INVLPG, I presume. No?
> 
> The idea is that you have a per-cpu address space.  Certain kernel
> virtual addresses would map to different physical address based on where
> you are running.  Each of the physical addresses would be "owned" by a
> single CPU and would, by convention, never use a PGD that mapped an
> address unless that CPU that "owned" it.
> 
> In that case, you never really invalidate those addresses.

But you would need to invalidate if the process moved to another CPU, correct?

