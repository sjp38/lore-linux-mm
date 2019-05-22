Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E62A5C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:38:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AA4020821
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 20:38:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AA4020821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08E636B0003; Wed, 22 May 2019 16:38:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03DC06B0006; Wed, 22 May 2019 16:38:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E47066B0007; Wed, 22 May 2019 16:38:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id BF2F56B0003
	for <linux-mm@kvack.org>; Wed, 22 May 2019 16:38:39 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id v77so3252709ywe.1
        for <linux-mm@kvack.org>; Wed, 22 May 2019 13:38:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=d+ndlJSLq+rU6RgWbIIbnH1PzqZ7zjvEvgMkuhh1tPQ=;
        b=j29YK1ghBE7Zt3G/XO/ptPar2BJ1j+wdnDLzLimvJPemPqaPXPeQ3dstwtRshGfZtz
         Hurmf6H923o6WRqJBZfH2qerXXZxCLqR06LCrR2KkyTsEfB2IZbEDHSK5yAO4OQrECSc
         40YvPtr8L4j+IbDCnO6nHtyfwzN7ZO0SZP4lwvCaH5tZ9o+0IAQojwHidVAHQEjRk18V
         OQiA5HIhe0kc8z4MYJhpgWlNSQs/wXVCEC55276mJl7JzgMQelzi1NiBOmTiZl0tfbJ8
         RAKCsn2NpqN5RSJTZDEqdulvqo7tkBpB9DrV36zgxfcalyuqyzheB0e34ub9k43gRz4M
         q/jQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWtCtrh0CV6EZ1k6XIXt7yY6pDcfBk7yD3B6bFHsXYpD1A23V8o
	03buWVwOE+U+iLq3VR69YvD2beBUXKvsLYxad70IsVLdnk4aurLHYqU1/BWs9LwecAt6teDFGkZ
	pgsv9Jhl2oJZpVkGgDG9fPopfXDaQoer7fr2JkDiEa57PoqL2mDGlENnQDWXxTyd88A==
X-Received: by 2002:a25:d957:: with SMTP id q84mr13128683ybg.52.1558557519458;
        Wed, 22 May 2019 13:38:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwaIYxKxE/zI/fvKz3TcIs8xCDwVI6sn5bzbKfPdiZCY7WRdC9VrsS2M4bfHF/V3CzRAX9E
X-Received: by 2002:a25:d957:: with SMTP id q84mr13128651ybg.52.1558557518619;
        Wed, 22 May 2019 13:38:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558557518; cv=none;
        d=google.com; s=arc-20160816;
        b=YnKSKx80NEUiZGdJymmGwYddxPU4rOXM8m/O/OSjC6bgA9bnZZCq01QgJBDP6XFhOW
         nflkjWcJeo00oZ0KGeGgHeXu9nuOMfyy9tpUHe5Rr/zVUMBv0QSHSLB2FgkSGcyqt1kv
         1zl7StVVIA3Rf15jGgyMv+N+pxmWpxWsObwWt7ZNKg7SuU1SQ5YASxbcaZwe/sfT1sFr
         DeQeyJNCpKD1NN8a4ZWrJjxg5o1WvI/P9G1rMC25BWCeStdfPmE1xRARQsf1Q151J/Cq
         vEG2SGidL+RvV/CE4PBg9gFfNWRshHDovi+yTRk50AW8wrIPdkc/KBUtlxcll+DdZbrk
         Lx5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=d+ndlJSLq+rU6RgWbIIbnH1PzqZ7zjvEvgMkuhh1tPQ=;
        b=GRaXpnsaRKBg2GVmJzeadx7BySyUJeZ5L5IKY28wuC9rJ6N4Kz8N+TNqbeFQEQrso2
         5Z9Sr7iNb/68gk4C5KSw3GTcTJ1/xRQ80/RmdH1pJW8/XRWsX9MxmP7YBASIlMw7IVvt
         eyBvWAthOs8HpePgKE79xMx3aTo1U9nj3oTEdPvIgCKHTMObrw6pfVqe1srteWOnjdXw
         itBq4opzvuOHqfDXOvV1F9frtm8zR7uUh2vprA82mbK6OiboN+dmnUR6xl8UsiUlh263
         fLDORcb2/JVl58LKNEAs5Y5fhKav27AxfFeZaNb6YE/QMITbGD3cAi004b3jSN5NUFWw
         4Jgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i82si7338370ywa.345.2019.05.22.13.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 13:38:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4MKbNnk106065
	for <linux-mm@kvack.org>; Wed, 22 May 2019 16:38:38 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2snbb8dhm8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 16:38:37 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 22 May 2019 21:38:36 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 21:38:33 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4MKcW4Y50397334
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 20:38:32 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5E2C5AE045;
	Wed, 22 May 2019 20:38:32 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 87F48AE04D;
	Wed, 22 May 2019 20:38:31 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.81])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 22 May 2019 20:38:31 +0000 (GMT)
Date: Wed, 22 May 2019 23:38:29 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        Borislav Petkov <bp@suse.de>,
        "Dr. David Alan Gilbert" <dgilbert@redhat.com>, kvm@vger.kernel.org
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
 <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19052220-0020-0000-0000-0000033F6D06
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052220-0021-0000-0000-0000219253D1
Message-Id: <20190522203828.GC18865@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220144
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(added kvm)

On Wed, May 22, 2019 at 12:21:13PM -0700, Andrew Morton wrote:
> On Tue, 14 May 2019 17:29:55 +0300 Mike Rapoport <rppt@linux.ibm.com> wrote:
> 
> > When get_user_pages*() is called with pages = NULL, the processing of
> > VM_FAULT_RETRY terminates early without actually retrying to fault-in all
> > the pages.
> > 
> > If the pages in the requested range belong to a VMA that has userfaultfd
> > registered, handle_userfault() returns VM_FAULT_RETRY *after* user space
> > has populated the page, but for the gup pre-fault case there's no actual
> > retry and the caller will get no pages although they are present.
> > 
> > This issue was uncovered when running post-copy memory restore in CRIU
> > after commit d9c9ce34ed5c ("x86/fpu: Fault-in user stack if
> > copy_fpstate_to_sigframe() fails").
> > 
> > After this change, the copying of FPU state to the sigframe switched from
> > copy_to_user() variants which caused a real page fault to get_user_pages()
> > with pages parameter set to NULL.
> 
> You're saying that argument buf_fx in copy_fpstate_to_sigframe() is NULL?

Apparently I haven't explained well. The 'pages' parameter in the call to
get_user_pages_unlocked() is NULL.
 
> If so was that expected by the (now cc'ed) developers of
> d9c9ce34ed5c8923 ("x86/fpu: Fault-in user stack if
> copy_fpstate_to_sigframe() fails")?
> 
> It seems rather odd.  copy_fpregs_to_sigframe() doesn't look like it's
> expecting a NULL argument.
> 
> Also, I wonder if copy_fpstate_to_sigframe() would be better using
> fault_in_pages_writeable() rather than get_user_pages_unlocked().  That
> seems like it operates at a more suitable level and I guess it will fix
> this issue also.

If I understand correctly, one of the points of d9c9ce34ed5c8923 ("x86/fpu:
Fault-in user stack if copy_fpstate_to_sigframe() fails") was to to avoid
page faults, hence the use of get_user_pages().

With fault_in_pages_writeable() there might be a page fault, unless I've
completely mistaken.

Unrelated to copy_fpstate_to_sigframe(), the issue could happen if any call
to get_user_pages() with pages parameter set to NULL tries to access
userfaultfd-managed memory. Currently, there are 4 in tree users:

arch/x86/kernel/fpu/signal.c:198:8-31:  -> gup with !pages
arch/x86/mm/mpx.c:423:11-25:  -> gup with !pages
virt/kvm/async_pf.c:90:1-22:  -> gup with !pages
virt/kvm/kvm_main.c:1437:6-20:  -> gup with !pages

I don't know if anybody is using mpx with uffd and anyway mpx seems to go
away.

As for KVM, I think that post-copy live migration of L2 guest might trigger
that as well. Not sure though, I'm not really familiar with KVM code.
 
> > In post-copy mode of CRIU, the destination memory is managed with
> > userfaultfd and lack of the retry for pre-fault case in get_user_pages()
> > causes a crash of the restored process.
> > 
> > Making the pre-fault behavior of get_user_pages() the same as the "normal"
> > one fixes the issue.
> 
> Should this be backported into -stable trees?

I think that it depends on whether KVM affected by this or not.

> > Fixes: d9c9ce34ed5c ("x86/fpu: Fault-in user stack if copy_fpstate_to_sigframe() fails")
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> 
> 

-- 
Sincerely yours,
Mike.

