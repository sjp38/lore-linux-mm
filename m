Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B06DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3058721B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 19:57:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="owg2EAXP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3058721B68
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C1D5C8E0002; Thu, 14 Feb 2019 14:57:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BCCD68E0001; Thu, 14 Feb 2019 14:57:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE3238E0002; Thu, 14 Feb 2019 14:57:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCE38E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 14:57:55 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 75so5607072pfq.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 11:57:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BdK7IaSpJfGdyre7bODL0VtCcEpshJ2Y4O0xLokGeZA=;
        b=rV2zUb7c4q1XmDhSDt3D8sJspV8kn1rBPwmQBz8ldQaOp6FBmALC6TBnNtF//3f8iN
         uGWdjnAeGQSNR3XpIgaBbZblFZv8nWDj4fT9uChtHjYStVzhdcljc8M3BEqx3DNEl9Ju
         5DjkGnnUEDg42dCg5BATE71BN96RTU/5oAmbVAxacu/2gdCT2swXjDcichW5rVSeD+m+
         MPV1EUy04Yr/drzqJbH/ZGR0iOx8XyBL27uZcenYVvzKLRX7Fvy9VdeklnQSL2u+yOqd
         8mRA8gxF7XWoVjPmT2zVSdTtIr9bm+gU0f0u0alFlv8hCZjmhvXy5z5Uts3fP+o/Y5Iv
         PnKA==
X-Gm-Message-State: AHQUAuYoRZX5nbxCPLXcmZXgXO4fFspKmoNyj+Ay6/7jeea4Yoy/tCrz
	6zR4WiZP0hBm1Y/x/xKnDJP1TcKJg/dVot43LFEDmqoNIt7iVAZMYJ6kIWX143yJnqi2M1P8Cck
	BFA4oCTi3WsZsVuM+EJ8Ww1nqB6n7ZVfKhmJ5Fs7GvnfITukHSubQmi/XBqb2AthdZQ==
X-Received: by 2002:a17:902:b68a:: with SMTP id c10mr5856745pls.248.1550174275109;
        Thu, 14 Feb 2019 11:57:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYUNJ68o+N869pL4Rv1bzOzDLchG7YLgGdiMZzKOEZShrzIPusCYkQOpWLJbJ9dEr3XnzUg
X-Received: by 2002:a17:902:b68a:: with SMTP id c10mr5856688pls.248.1550174274366;
        Thu, 14 Feb 2019 11:57:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550174274; cv=none;
        d=google.com; s=arc-20160816;
        b=U/VUfUotY7eJP1e4EILx4U0cBCCUSGDXijt2GMyBEuvMznUjZD7tjkcuX8/lPPshzb
         BIbXSdkmIYLWvmD4UYpeNxTnM3R/INb2Fk/3bZtBS06tLV/rXnDgiixVPImyh7LraTjk
         PaH7zoy9eRBJi4uXkUXlLicD2TNO42+swjgx9JkwypiWDvJISjmxFJLX9RBny87SuGDg
         EPWVlNAZiKLIhEdJrcGIGCxci7fM/Qx7y9nmGHgs04i1YquSOPvnu/HAGGeS4opv7ks7
         eEOl/2CZMhqiAEz+kH+N7Pc6QzAt6uCHISCCLUQ49U63t5cistWCvhyGnoSLQDpznQj+
         wGjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=BdK7IaSpJfGdyre7bODL0VtCcEpshJ2Y4O0xLokGeZA=;
        b=nUmrlFXWUH8+LoCeK3nMlRTKQEfKsvGdNGy9PQihzhq4yMmGjinnzsaA/ksuJ81j/V
         k3w9OHN0qHERneq06NoSQl1Kv5vfLx3ozqgRqwqp+uWQIKhYhc3+T5yj/lXxCpwFKOf1
         6V9+e/UzobaMOH8KCQLr5W+F4HLASwLH2NbOO50tbXULavCO4ZfRU+44uE3VsxOOs3fg
         4l3WZPE0/ndW48hDJ+YQcRyhB3hSs+/rWGqz+hifMvg5YsJOdh6jPNsapNmX+UqPRfj3
         JDbbZ+ew5x+OfOyXeLV+O0Xf3Acdbuv49ddOhafFRe5jBYKJH/v1c4utWfRY4APyQgXX
         LP6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=owg2EAXP;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 33si3354729plh.245.2019.02.14.11.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 11:57:54 -0800 (PST)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=owg2EAXP;
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1EJsITk073232;
	Thu, 14 Feb 2019 19:57:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=BdK7IaSpJfGdyre7bODL0VtCcEpshJ2Y4O0xLokGeZA=;
 b=owg2EAXP1djY4nOw3m8VNIzE98O8OriShbmSSMKZ1A19elg+OjugPa4ORsAae1iR/QG+
 Oo6TItCage0cFqLHvah7MyhhQEJRLw3heZpg0f9FxV8KjBacCmhDbU4A0xmkJ4AE0tW7
 7J9JF0zShtWDBE+r9ZN2h7CQ6evngnuEYCI2DcA3CDxWWAikNj2v6M/+F1z0RzJ8PftT
 w/OicGnyFF60fSAZPPiq1gNdWsq+Jc80DNuUYrKuzTkrqjKuKEtmKgryWLQec1RjtvWO
 whVfMYxFhwr12ksKkKKbj0LUcJjPeYPtDBVapSvKu0btUzQCxs69XCHlEjHQ3KEkgP2z tg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2qhreea5de-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:57:36 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1EJvZQN015680
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 14 Feb 2019 19:57:35 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1EJvXGY021984;
	Thu, 14 Feb 2019 19:57:33 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 14 Feb 2019 19:57:33 +0000
Subject: Re: [RFC PATCH v8 13/14] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
To: Dave Hansen <dave.hansen@intel.com>, juergh@gmail.com, tycho@tycho.ws,
        jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org,
        liran.alon@oracle.com, keescook@google.com, akpm@linux-foundation.org,
        mhocko@suse.com, catalin.marinas@arm.com, will.deacon@arm.com,
        jmorris@namei.org, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
        dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
        boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
        joao.m.martins@oracle.com, jmattson@google.com,
        pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de,
        kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com,
        labbott@redhat.com, luto@kernel.org, peterz@infradead.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        x86@kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-kernel@vger.kernel.org
References: <cover.1550088114.git.khalid.aziz@oracle.com>
 <98134cb73e911b2f0b59ffb76243a7777963d218.1550088114.git.khalid.aziz@oracle.com>
 <a6510fa8-e96d-677b-78df-da9a19c4089b@intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <95fb62d4-1dbc-e420-74c1-ff929c5552e1@oracle.com>
Date: Thu, 14 Feb 2019 12:57:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <a6510fa8-e96d-677b-78df-da9a19c4089b@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9167 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902140133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/14/19 10:42 AM, Dave Hansen wrote:
>>  #endif
>> +
>> +	/* If there is a pending TLB flush for this CPU due to XPFO
>> +	 * flush, do it now.
>> +	 */
>=20
> Don't forget CodingStyle in all this, please.

Of course. I will fix that.

>=20
>> +	if (cpumask_test_and_clear_cpu(cpu, &pending_xpfo_flush)) {
>> +		count_vm_tlb_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
>> +		__flush_tlb_all();
>> +	}
>=20
> This seems to exist in parallel with all of the cpu_tlbstate
> infrastructure.  Shouldn't it go in there?

That sounds like a good idea. On the other hand, pending flush needs to
be kept track of entirely within arch/x86/mm/tlb.c and using a local
variable with scope limited to just that file feels like a lighter
weight implementation. I could go either way.

>=20
> Also, if we're doing full flushes like this, it seems a bit wasteful to=

> then go and do later things like invalidate_user_asid() when we *know*
> that the asid would have been flushed by this operation.  I'm pretty
> sure this isn't the only __flush_tlb_all() callsite that does this, so
> it's not really criticism of this patch specifically.  It's more of a
> structural issue.
>=20
>=20

That is a good point. It is not just wasteful, it is bound to have
performance impact even if slight.

>> +void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long e=
nd)
>> +{
>=20
> This is a bit lightly commented.  Please give this some good
> descriptions about the logic behind the implementation and the tradeoff=
s
> that are in play.
>=20
> This is doing a local flush, but deferring the flushes on all other
> processors, right?  Can you explain the logic behind that in a comment
> here, please?  This also has to be called with preemption disabled, rig=
ht?
>=20
>> +	struct cpumask tmp_mask;
>> +
>> +	/* Balance as user space task's flush, a bit conservative */
>> +	if (end =3D=3D TLB_FLUSH_ALL ||
>> +	    (end - start) > tlb_single_page_flush_ceiling << PAGE_SHIFT) {
>> +		do_flush_tlb_all(NULL);
>> +	} else {
>> +		struct flush_tlb_info info;
>> +
>> +		info.start =3D start;
>> +		info.end =3D end;
>> +		do_kernel_range_flush(&info);
>> +	}
>> +	cpumask_setall(&tmp_mask);
>> +	cpumask_clear_cpu(smp_processor_id(), &tmp_mask);
>> +	cpumask_or(&pending_xpfo_flush, &pending_xpfo_flush, &tmp_mask);
>> +}
>=20
> Fun.  cpumask_setall() is non-atomic while cpumask_clear_cpu() and
> cpumask_or() *are* atomic.  The cpumask_clear_cpu() is operating on
> thread-local storage and doesn't need to be atomic.  Please make it
> __cpumask_clear_cpu().
>=20

I will fix that. Thanks!

--
Khalid

