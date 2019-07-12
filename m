Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6DC7C742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74A7120863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 08:10:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DvsaEaFN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74A7120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3F8D8E0127; Fri, 12 Jul 2019 04:10:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF0738E00DB; Fri, 12 Jul 2019 04:10:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E06F68E0127; Fri, 12 Jul 2019 04:10:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C60F28E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 04:10:11 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so9736765ioh.22
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 01:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2tqEcmeLMeBgU3gGieUNuwSnxjbrQ/jmkTtByRX3RIE=;
        b=kE493WNfWGn1G+W+2qpTh4hc9jVxLIcc1wMruSqLBKqKjDvleIqfb1Zi8HATVSP8Wy
         wTEFBKORrG/X9TEiUiEQH+6yWF3EESfglgp0voe/uV57obxdA3drKP2R//0TMwieoDsh
         LTZ875c+u5kG7ljp7ZQlifX9AjRR8xDqJUZT8kcstvOqP1HAeOhEH3XvjmmKuYgCOWox
         MWQm9fh+Q95xuNJoxBSkE/Oy8Q0hdzTV0Xjqow6KQcEZKISard2hN3gbUml4xs9mAuk3
         85ZtDo0NOrT4yBN9zn8j/cNGpJ84tNZkfT+z8wmmk27huY0fqNIdE9XuvRXIWJXiw0Jc
         4GHg==
X-Gm-Message-State: APjAAAVareLee5UWH8q65iBh6OkTCklB4cJEs7t+xarNWJVa2gAQmuFo
	yLcL9Yf3ImB1pIsFzbWyLDeQ7wj4iW7Cg9KsaytXO55xXiDT3DjCcT/2fW/9ZW80WcQojyG18tS
	wRGhvvb3f9GFJAAurnHwDolgk2VymAWs1/bIpzWPj2GBvHbgQYvhkdeUrwAdOoklsyA==
X-Received: by 2002:a6b:8b0b:: with SMTP id n11mr9480722iod.101.1562919011586;
        Fri, 12 Jul 2019 01:10:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUJPtEBEZMhXtrldqYOB9HH3piOfk+/viIfAWmuSI4/MTVWo4MoGY0Y0XrYOHBJDQd264H
X-Received: by 2002:a6b:8b0b:: with SMTP id n11mr9480681iod.101.1562919010948;
        Fri, 12 Jul 2019 01:10:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562919010; cv=none;
        d=google.com; s=arc-20160816;
        b=k0KEiJTRkGSHvyAvoA5brHo+khNIRvqw9Cgbo2xAguMdm4GS6lKYSnXqygcsnsq09z
         t+5W6+59sru3TFpHwM0d6UshYkR2JLLhr423JV99BWxifDIVXEOQ37fg93Bdu4CCX8SQ
         gWgwl5ZXTOLi1M1haHNS4tKQ3a5mlJu4mU7RZJ8n5LEVIfLobnrkDVd+XDWieAdGEUwf
         h16d8t9MeIq/W0AKaGpD1SK5ZrmNCZe1KrtjCBZkeRWnc0GrAzwWrbYb3PvyhVjFgL6m
         I9gT0Nzbpf6bkxrm1kDjdZxFthmhZNibmI3YOD3UJGPxtzsre0+vJiyP/IIk5WTGZaZe
         t96A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=2tqEcmeLMeBgU3gGieUNuwSnxjbrQ/jmkTtByRX3RIE=;
        b=fBe5xXZ5ys8058kORyBJ7ICmO96XiFBoAt5vBicx5KzPEWlv4XhibSNIKOFSODThvL
         MOthrDhz11Dza6GQMuyin00swv288bPpBBvCYWeejCc92I5cE9fQT8cMR3/kdO0r2vfW
         6PzFj71kYF9VP+y8vrvI8GqWty3Uo1pGDxIq0hA0jlT/srTeERvVFrlFhXpbC+GEODwS
         tmPVZf5abcpnXNSWXQjGQE+6qt6N+82ZqvczwJILs58pUd7YcqsG2mx7hksUeMMNA3hh
         5vPiNneCnO7OAqx9UuN3qofoLwvu+weZmqi3kCGF31aXI/taSHI1/1Fs5244iAxO0d07
         iHUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DvsaEaFN;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c7si11238200iot.78.2019.07.12.01.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 01:10:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DvsaEaFN;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6C896rx002321;
	Fri, 12 Jul 2019 08:09:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=2tqEcmeLMeBgU3gGieUNuwSnxjbrQ/jmkTtByRX3RIE=;
 b=DvsaEaFNL7mXZf4t8TbD1WICbedvS6gXnuNWRU6+EhUI9XdmryDQbk9oboMU6PwhEa/d
 28l5JpbAOTVmdiUJOo0kUEkSZwQzVV5A/3elCDczMiD1LMVgxz2Cl70jq+95JaCFwmiY
 88y+spRDwcQsEhg4fXreM4bRNOTFII/2UECL515bHyVQ3scJP53TAix2Uv+9ajtzU2K3
 6ScCbuMVR79YPhRS6tYss1/BMcLK9e6XvckJpnixvGoXnD57Nx/yYHQkBFsaE2wxsNK6
 UEU7tyMVp2A3mqIqhf+iNdFA2/297k2DBHX65Vvl76VGG0Wdz45MCDDoPXqJby5YEEDh KA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2tjk2u47nv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 08:09:59 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6C87a4X087501;
	Fri, 12 Jul 2019 08:09:58 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2tmwgyn6kp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 08:09:58 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6C89tfH027689;
	Fri, 12 Jul 2019 08:09:56 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 01:09:55 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <2791712a-9f7b-18bc-e686-653181461428@oracle.com>
Date: Fri, 12 Jul 2019 10:09:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120085
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120086
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 12:38 AM, Dave Hansen wrote:
> On 7/11/19 7:25 AM, Alexandre Chartre wrote:
>> - Kernel code mapped to the ASI page-table has been reduced to:
>>    . the entire kernel (I still need to test with only the kernel text)
>>    . the cpu entry area (because we need the GDT to be mapped)
>>    . the cpu ASI session (for managing ASI)
>>    . the current stack
>>
>> - Optionally, an ASI can request the following kernel mapping to be added:
>>    . the stack canary
>>    . the cpu offsets (this_cpu_off)
>>    . the current task
>>    . RCU data (rcu_data)
>>    . CPU HW events (cpu_hw_events).
> 
> I don't see the per-cpu areas in here.  But, the ASI macros in
> entry_64.S (and asi_start_abort()) use per-cpu data.

We don't map all per-cpu areas, but only the per-cpu variables we need. ASI
code uses the per-cpu cpu_asi_session variable which is mapped when an ASI
is created (see patch 15/26):

+	/*
+	 * Map the percpu ASI sessions. This is used by interrupt handlers
+	 * to figure out if we have entered isolation and switch back to
+	 * the kernel address space.
+	 */
+	err = ASI_MAP_CPUVAR(asi, cpu_asi_session);
+	if (err)
+		return err;


> Also, this stuff seems to do naughty stuff (calling C code, touching
> per-cpu data) before the PTI CR3 writes have been done.  But, I don't
> see anything excluding PTI and this code from coexisting.

My understanding is that PTI CR3 writes only happens when switching to/from
userland. While ASI enter/exit/abort happens while we are already in the kernel,
so asi_start_abort() is not called when coming from userland and so not
interacting with PTI.

For example, if ASI in used during a syscall (e.g. with KVM), we have:

  -> syscall
     - PTI CR3 write (kernel CR3)
     - syscall handler:
       ...
       asi_enter()-> write ASI CR3
       .. code run with ASI ..
       asi_exit() or asi abort -> restore original CR3
       ...
     - PTI CR3 write (userland CR3)
  <- syscall


Thanks,

alex.

