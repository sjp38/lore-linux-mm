Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EE5EC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:44:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19AF1208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:44:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5DX7PGyy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19AF1208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EE208E0121; Fri, 12 Jul 2019 03:44:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69E6B8E00DB; Fri, 12 Jul 2019 03:44:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58D198E0121; Fri, 12 Jul 2019 03:44:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3B34B8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:44:21 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id 132so9712243iou.0
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:44:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8T/t61hH+mxP53WzfTtGAJxdQjq9tmKdl9zDJcQJWT0=;
        b=BltKXfK2Q6BWI7BX0IymSWZIfCIZmik4uAT/yh7kiQA1JzkfUIg1JM8/hr3uaUePzu
         f0nmTKiheLGaXlCa8ioMqmEDi1ajz+Xpob8ky195NKAxyt3ZzwjaXHEjZIDMFeR8jxNe
         bt3CKuVqStVkhWRFGa6WXqCBKZNeXxqmZ31EZSY7TLuC+PCTsoESoOy4aAM3skZsbdT/
         QbcdFZwLd4979oGZjzrjHl0tBI72BMoiT7nXI/2N2qbaISmZnwB5Sts4R1ZKYupLHL+m
         sQ1Sokc+jDGA8tOZZavKdSPIn+JupJYU2WEEalsWepCU/MNWIFCOrPRU8SDfhks7CAl+
         BOkA==
X-Gm-Message-State: APjAAAXSYRJxgUSCa4UDeIFOFh6unyZ094mCNrr2KwnecINyuzsIodeQ
	8xJfV8+gC4LwSf+CY6yWVnCN9NP2MZh2bGfHxBFhUhsQ0IOvxdrbI3rWgKRb/HvS1hTmm8kLeYE
	lcbUZ1Y0dYiNb+qz/4iDJ+J1LJw7CKLrGYKNkTiLkx8aE62iCR5WpDJOHxBhOqMc5Jg==
X-Received: by 2002:a5d:9957:: with SMTP id v23mr8933023ios.117.1562917460982;
        Fri, 12 Jul 2019 00:44:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyJAKG1Vftn7DXBt2d+PIN9pyqlv7SnBZKWFXbM7jAtHGQNChqzr3hTp0xsuZ+CWMdp5lA+
X-Received: by 2002:a5d:9957:: with SMTP id v23mr8932987ios.117.1562917460310;
        Fri, 12 Jul 2019 00:44:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562917460; cv=none;
        d=google.com; s=arc-20160816;
        b=BHJuWexxPGkJHi7/Rg2Nt2scTixqMoEV9Wd85GQU4xkyRMXMtkqMWzyaWjpwV9HnGK
         5afLMKEZa+WZ6g/kHAIy+AisK87Nx8NQU8nrmxUbBajsbEcbv/Pw+m8dJgiqIVRzK9/K
         fzTRWazTuRqbkqld/yPrP8ObyVVFHe6yA7pwtZC0oxqrPolPEDasb+TOQQH5Xr6aGGWt
         KWi68A/SpoynWy9zsv8gBZGT+4sT69uhR6JMX/9rGZackgMLTy+fkRejgUU59xT8EVw8
         TEyHnIhtrYeCow/HSA9H4+nHc0VhCXmlw4gTF4KcmBrAVejPxdnWXdaRu2okhO+mY1y2
         uwNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=8T/t61hH+mxP53WzfTtGAJxdQjq9tmKdl9zDJcQJWT0=;
        b=up9t/S5+fzDTuDVb1uGAzqF4KCQDXJ/UVKczzSsCJkXDyBzqP0EHkK8nJvggJ+4UQW
         l7+eYRlMgvy5URPKuTBr1YDxsW2NMgVQSZ0SH6anCm4F6Hi/VUbUD7g0HO4ZK30V1icN
         66ndcEAnTzjEuhO2eQwen7/LYlXm028VD1rqxiZSlH9bsjHtFbigm2dthxtB21h2N3Zn
         mWuypRhdLr0tM8AREPUSvoM0Hs19+77DmsXvr45K8JUzCr4Gi4T22Da2zExaFZAbQe8d
         ry4ZUE9Poae9pHAIjg052bXmcdnJ0ZirE6tgRLT4jKrKTWKRg58z7jcYuXo6NhJKf92/
         tAEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5DX7PGyy;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id s1si12603161jam.72.2019.07.12.00.44.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 00:44:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=5DX7PGyy;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6C7i7f6178923;
	Fri, 12 Jul 2019 07:44:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=8T/t61hH+mxP53WzfTtGAJxdQjq9tmKdl9zDJcQJWT0=;
 b=5DX7PGyyiqAuHqdElQqOA4nGLmMdtiOKrdKtqVkBCGeRmC1rNLNWcBzr/XdK+h1EBtOE
 hQ+Q6neY2rtBbsU8vFeLSaXP+vl6vLk9dU25fu42tJrcGwfGOkPPySvBVMJSIQcoN8Ok
 xqMS2nf2qUM4tEKg1uD5x3Mk2k3EJ8DiF78j7sC1lIF9lBTUOrzSDX8B0kHKmnvxe5DJ
 PO1MVtehBbtIbtqHCPfUkI39iBsWtpMIDc5BuK5Nkt9DqRuyGdf3pBcbGmaK3w2zxAOd
 tPMNV8l2yuBlHrT0j3BPgSSzV2ri/NhdC80csgqE87Vlp1/u4WUCNR7Vf912WOzePgIJ Pg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2tjk2u445s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 07:44:07 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6C7hXBw019439;
	Fri, 12 Jul 2019 07:44:06 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2tmwgympn6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 07:44:06 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6C7i3Sq030229;
	Fri, 12 Jul 2019 07:44:04 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 00:44:03 -0700
Subject: Re: [RFC v2 01/26] mm/x86: Introduce kernel address space isolation
To: Thomas Gleixner <tglx@linutronix.de>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <1562855138-19507-2-git-send-email-alexandre.chartre@oracle.com>
 <alpine.DEB.2.21.1907112321570.1782@nanos.tec.linutronix.de>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <42eac268-9b3a-b444-8288-76d57faf0826@oracle.com>
Date: Fri, 12 Jul 2019 09:43:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907112321570.1782@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120080
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120080
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/11/19 11:33 PM, Thomas Gleixner wrote:
> On Thu, 11 Jul 2019, Alexandre Chartre wrote:
>> +/*
>> + * When isolation is active, the address space doesn't necessarily map
>> + * the percpu offset value (this_cpu_off) which is used to get pointers
>> + * to percpu variables. So functions which can be invoked while isolation
>> + * is active shouldn't be getting pointers to percpu variables (i.e. with
>> + * get_cpu_var() or this_cpu_ptr()). Instead percpu variable should be
>> + * directly read or written to (i.e. with this_cpu_read() or
>> + * this_cpu_write()).
>> + */
>> +
>> +int asi_enter(struct asi *asi)
>> +{
>> +	enum asi_session_state state;
>> +	struct asi *current_asi;
>> +	struct asi_session *asi_session;
>> +
>> +	state = this_cpu_read(cpu_asi_session.state);
>> +	/*
>> +	 * We can re-enter isolation, but only with the same ASI (we don't
>> +	 * support nesting isolation). Also, if isolation is still active,
>> +	 * then we should be re-entering with the same task.
>> +	 */
>> +	if (state == ASI_SESSION_STATE_ACTIVE) {
>> +		current_asi = this_cpu_read(cpu_asi_session.asi);
>> +		if (current_asi != asi) {
>> +			WARN_ON(1);
>> +			return -EBUSY;
>> +		}
>> +		WARN_ON(this_cpu_read(cpu_asi_session.task) != current);
>> +		return 0;
>> +	}
>> +
>> +	/* isolation is not active so we can safely access the percpu pointer */
>> +	asi_session = &get_cpu_var(cpu_asi_session);
> 
> get_cpu_var()?? Where is the matching put_cpu_var() ? get_cpu_var()
> contains a preempt_disable ...
> 
> What's wrong with a simple this_cpu_ptr() here?
> 

Oups, my mistake, I should be using this_cpu_ptr(). I will replace all get_cpu_var()
with this_cpu_ptr().


>> +void asi_exit(struct asi *asi)
>> +{
>> +	struct asi_session *asi_session;
>> +	enum asi_session_state asi_state;
>> +	unsigned long original_cr3;
>> +
>> +	asi_state = this_cpu_read(cpu_asi_session.state);
>> +	if (asi_state == ASI_SESSION_STATE_INACTIVE)
>> +		return;
>> +
>> +	/* TODO: Kick sibling hyperthread before switching to kernel cr3 */
>> +	original_cr3 = this_cpu_read(cpu_asi_session.original_cr3);
>> +	if (original_cr3)
> 
> Why would this be 0 if the session is active?
> 

Correct, original_cr3 won't be 0. I think this is a remain from a previous version
where original_cr3 was handled differently.


>> +		write_cr3(original_cr3);
>> +
>> +	/* page-table was switched, we can now access the percpu pointer */
>> +	asi_session = &get_cpu_var(cpu_asi_session);
> 
> See above.
> 

Will fix that.


Thanks,

alex.

>> +	WARN_ON(asi_session->task != current);
>> +	asi_session->state = ASI_SESSION_STATE_INACTIVE;
>> +	asi_session->asi = NULL;
>> +	asi_session->task = NULL;
>> +	asi_session->original_cr3 = 0;
>> +}
> 
> Thanks,
> 
> 	tglx
> 

