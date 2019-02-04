Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7CA78C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 10:47:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B80E2070C
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 10:47:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B80E2070C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67B288E003D; Mon,  4 Feb 2019 05:47:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629B18E001C; Mon,  4 Feb 2019 05:47:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F3858E003D; Mon,  4 Feb 2019 05:47:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 217548E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 05:47:08 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id t10so1594033qtn.4
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 02:47:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=CBPmiwmhByExA/ctfiKGvoaP57ez+p1peMJwkaWsQpg=;
        b=kc+j8KS5v3r7QtL9tbCO0uAKlSsUHDcnn1h8XeG/74RhCZcHMAzyZWCpX97v2v8GHw
         i0ag3J1/RcK6tR4flsrHDGRGYcgj/kFZgp5/DzRauW5g8lA9l+JcDU1/JEDF1RKQ/1H+
         FnfDaFC7B1q1YmeVagpIX7TrjAp/+gc00dGeNsJpKuEt3cBhZdEyz+oYIVrHwzBxQxpC
         3k5GOQEClEZgCTF8JyZrcUljy/lLl8Zk4aNgGBH1BXB9cvVVGbwX5Mo2b4J12qsl5S0Y
         HIU5J/bdbFHX7H9gyhCBqYbrvq/fULBL2Ou/WpKwNLPcFmupQlBpxPLrs42N066v9enV
         2s8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfBLaqDOjq6VCzM3HwjQQZ0usYUl7pu3m/8JOqf8KKfvvj/V5bQ
	3ESYDHrN6HW5kZ3XNnVy3ZKYlvzTnJHcN5m+u4hepidzgw/cIXbAUBA+tNrFJObnPAMHFK1rlz6
	bbxLzc9bBnAFOjPxI72bF0csTfNkgpSv+P3SO9W2+KtsCfnl2d6bRBcrGT3KylVygaw==
X-Received: by 2002:ac8:75cc:: with SMTP id z12mr48506426qtq.249.1549277227884;
        Mon, 04 Feb 2019 02:47:07 -0800 (PST)
X-Google-Smtp-Source: ALg8bN65AbCAT7FYEyOGlBlMzGlDLBk7oKyeEl0kf6o7bnDut1G76SZ/pDG3ZEzk8ApfTykMNNDH
X-Received: by 2002:ac8:75cc:: with SMTP id z12mr48506389qtq.249.1549277227068;
        Mon, 04 Feb 2019 02:47:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549277227; cv=none;
        d=google.com; s=arc-20160816;
        b=JHYbDwmn1VwYg7mawG1VI99CsDsLtH5GMJ3hz5GfSvyPI1SM+QlyNf11u+YqeeI8r8
         py3aE3uspVRgDOp+F1RD311tAHjNE24W/vEvraCV/L3Ndlp7dXFnvOLXYBY+1h2aKvfe
         ObSkSacFKuJZTUIxB4Y5Gtdrypr2ZsR5rfanyWRwcs1RoUmQE3n0Cl5h1je4MOowwKLW
         PTCysIEP039IsglsNYBUC5gvcyX6FX70/ODeRv5LzSgCuk4diLVGf7lLAjCeVWTJrdeB
         mD8Oh4veWLyhq2Y7IK6di88TYfahBz3mVx49zi3ExONzresdV9R+ZQLom/l+mZ9r16d0
         O5uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=CBPmiwmhByExA/ctfiKGvoaP57ez+p1peMJwkaWsQpg=;
        b=raw2evoQaGFNhCbchSA0s9Da/kgJmAeBvz5XmNt82no+weidX//bqOUfDuTR7XxtZr
         B1/6kavQwrrnu31VMZdDXamBLm514o3oOAFEAafz9PWVjgAYQBhOVkuxMx1Qhx49lH+3
         wZRNkTSX4fw9F/vFg5ARxzCmBMIHJLgFQBQ/Ufu6IwnfZsN0805dsCMIYhBOCoKGgBiZ
         C+cMl3oji9yXbw0wKkJw7svMd1BcsBox5GWeIUB5o5bLiVcb4PAeoCseGszO8Njy3wSc
         1sb35K/WmQ2jzfqorBC0wI7utfiu4yTVMDe6JjZuiV81n2pevlQhe1M7ppyFlkAowo8r
         SweQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c11si1914499qvd.92.2019.02.04.02.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 02:47:07 -0800 (PST)
Received-SPF: pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of pbonzini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=pbonzini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CC7A5750CE;
	Mon,  4 Feb 2019 10:47:05 +0000 (UTC)
Received: from [10.36.112.65] (ovpn-112-65.ams2.redhat.com [10.36.112.65])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6861160851;
	Mon,  4 Feb 2019 10:46:56 +0000 (UTC)
Subject: Re: [RFC][PATCH v2 14/21] kvm: register in mm_struct
To: Peter Xu <peterx@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Nikita Leshenko <nikita.leshchenko@oracle.com>,
 Christian Borntraeger <borntraeger@de.ibm.com>, kvm@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>,
 Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>,
 Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>,
 Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>,
 Zhang Yi <yi.z.zhang@linux.intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.894160986@intel.com> <20190202065741.GA1011@xz-x1>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=pbonzini@redhat.com; prefer-encrypt=mutual; keydata=
 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
 uUHgL9dKIfvpm+rNXRn9wAwGjk0X/A==
Message-ID: <f23265d4-528e-3bd4-011f-4d7b8f3281db@redhat.com>
Date: Mon, 4 Feb 2019 11:46:54 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190202065741.GA1011@xz-x1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 04 Feb 2019 10:47:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/02/19 07:57, Peter Xu wrote:
> 
> I'm thinking whether it's legal for multiple VMs to run on a single mm
> address space.  I don't see a limitation so far but it's very possible
> I am just missing something there (if there is, IMHO they might be
> something nice to put into the commit message?).  Thanks,

Yes, it certainly is legal, and even useful in fact.

For example there are people running WebAssembly in a KVM sandbox.  In
that case you can have multiple KVM instances in a single process.

It seems to me that there is already a perfect way to link an mm to its
users, which is the MMU notifier.  Why do you need a separate
proc_ept_idle_operations?  You could change ept_idle_read into an MMU
notifier callback, and have core mm/ core combine the output of
mm_idle_read and all the MMU notifiers?  Basically, ept_idle_ctrl
becomes an argument to the new MMU notifier callback, or something like
that.

Paolo

