Return-Path: <SRS0=KwX8=RE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9307C43381
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 17:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D34C20857
	for <linux-mm@archiver.kernel.org>; Fri,  1 Mar 2019 17:52:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JEyoc1et"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D34C20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F21188E0003; Fri,  1 Mar 2019 12:52:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED1FD8E0001; Fri,  1 Mar 2019 12:52:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D99908E0003; Fri,  1 Mar 2019 12:52:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 97DA28E0001
	for <linux-mm@kvack.org>; Fri,  1 Mar 2019 12:52:36 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 59so18228325plc.13
        for <linux-mm@kvack.org>; Fri, 01 Mar 2019 09:52:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=NpucD7YBrSs74vzv0AXK91DfS+GP9Fp13cRwteMq25o=;
        b=LSGQIAlLRuL2HNAROzh/y2XmbRbdRRgPqqhto4PSQLW3tD28/yvdYXKo5IhFFwwFej
         O39gWhJO4OVr6eMbmO5Le/+ipS8TSzJt5QlXpsQfAMbgdNl3RlQngUJ+7965JbfRMyEm
         rB1V99ykdsb/JWbhc67SMLeCrDDOKuyrnsN1YT4OQUHjio5b4EcagxnZuwmN2kt0m7VZ
         eTO+llOlmDHE6JTfGfpCy5ag9hAhhEU3J9pcgSi4F11UKn/ltBo7CHFSeY1sIx+dfkaL
         JXJtKtXY5OQgTObaC7m5y/hle301P1QFiwCXxf/6EpOT/KcH1M2ln+ZINMJC2gB3NLns
         gAcQ==
X-Gm-Message-State: AHQUAuYgKM0Q0kR/v+7rWGuZANArKWHMXqP+yZNUjonllXc0tQQcBdkA
	SL1nagcBEW/cdJdTW0LHWw9li8jwJalU7DPrVgBx/5LC0MtbmSysPGf0C9o/kVNdLZUhVhMuZDJ
	fAJm8M42IlmJIBS7XA9O+tb29APZXjgTGc9/z3w4msiGpRXZJnFGhvKVojMSsYPdY7A==
X-Received: by 2002:aa7:924e:: with SMTP id 14mr6840477pfp.30.1551462756268;
        Fri, 01 Mar 2019 09:52:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYul2bBsedZLy8GDoBOTplkOO6IKZTUzihGY4S2tiYQITso/oX90J5z5we52Mv24d3/+7IK
X-Received: by 2002:aa7:924e:: with SMTP id 14mr6840361pfp.30.1551462754787;
        Fri, 01 Mar 2019 09:52:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551462754; cv=none;
        d=google.com; s=arc-20160816;
        b=F0B32EuhyNsEgeMOkO5QjTUA6vFiee+i4dCBFxarqq9DyQMRKsokghJQq4AlSHAwd2
         45gXWfPxjGmQFw7yARCU0Yqe42WUWRIokbNOW3FIj1sG8fWZWAGB28wqBqMjdQKCzwYE
         8kHJ6TdORsF7v7DJpNfosfyOEambPSMdqgzlfJn3JEkSqJOwdoQS71vjQLp+tJmFg2C8
         eJ/dABiwxfaDUE1Rdy2+fkgi7K6h2jmCEgFumTKETVkrS5UiP36ZWd3PPCbO2mMcZj8J
         lk1OlM2MlClu3R0VLSOBS4Skeg2uJOqNUUfOhM5NT8JkfngdeG0QqKa4LNZ52Hf/XDHv
         jsaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=NpucD7YBrSs74vzv0AXK91DfS+GP9Fp13cRwteMq25o=;
        b=md9QjTYACyZBk8lKKcAXURftBsTjwsiu/HVrko9N3hDeN4uw6ckn4DMi98ls2h857R
         GWY+fYyeEO4RV4ng2mLYOC5HrM0s8Gpici2+fJcraKjmngYej7xNO17cCKF9d21h/PsC
         bfNs57U607wJrtkj1Rvebf++rrqWP/s/bfSjK2KfPenK5tllPlXhOTbEobdmJ/55yn8G
         o707rBgNFIFPg8O49nNOY/cBZ4+Jt305akUZQnMbU7nTS0LmMTRtYOFWrhgyEa13DfZJ
         eJvOK5ao5x4ltLXAeVPDFu9K8K0kY77bs66Nfnnig/X5OYB3WyIdIHi5FFaUKH40a6oS
         vy/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JEyoc1et;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u69si20292994pgd.161.2019.03.01.09.52.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Mar 2019 09:52:34 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JEyoc1et;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x21Hn5jo062465;
	Fri, 1 Mar 2019 17:52:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=NpucD7YBrSs74vzv0AXK91DfS+GP9Fp13cRwteMq25o=;
 b=JEyoc1et9IUl4twUIN7FXN5HbH3g9uCVH6yniiL/mlA6a0Njg1bpBZ3TlW/+rOgFgtnF
 ko5cw+9Y4gGEflsAEaeReQSQLLwb2eggXY+2FMlDTVmt6CYjXsVNDeFG98zGMtCKt5Yk
 Fq4OLiaoXpNOX1gKniCDuEEuTulYVV8O4rJtPTOzt7Zmk+uIuAf9vwbyJJP62RWCqIT5
 LOD5TRMphV1Ye90VpvGC3k6o0NTQHttJ9NOYRiULbbMt/NfT8zOxJp1fnVOccCAGJLOO
 ID0LYvleQ2Yn00z94C+aNxpOC9QHc40ZkLvYPu8TkCUHlAEp+QFfTOy1fisakExP8i21 Sg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qtupervyr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 01 Mar 2019 17:52:04 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x21HpwU5007124
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 1 Mar 2019 17:51:58 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x21Hpqdx018558;
	Fri, 1 Mar 2019 17:51:53 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 01 Mar 2019 09:51:52 -0800
Subject: Re: [PATCH v4 4/4] hugetlb: allow to free gigantic pages regardless
 of the configuration
To: Alexandre Ghiti <alex@ghiti.fr>
Cc: Dave Hansen <dave.hansen@intel.com>,
        Yoshinori Sato <ysato@users.sourceforge.jp>,
        Rich Felker <dalias@libc.org>,
        "David S . Miller" <davem@davemloft.net>,
        Vlastimil Babka <vbabka@suse.cz>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon
 <will.deacon@arm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
        x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
        Andy Lutomirski <luto@kernel.org>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
        linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
        linux-mm@kvack.org
References: <20190228063604.15298-1-alex@ghiti.fr>
 <20190228063604.15298-5-alex@ghiti.fr>
 <9a385cc8-581c-55cf-4a85-10b5c4dd178c@intel.com>
 <31212559-d397-88fb-eaec-60f6417436c8@oracle.com>
 <6c842251-1bed-4d79-bf6d-997006ec72e2@intel.com>
 <6ea4119a-0ecb-511d-3aab-269004245a08@oracle.com>
 <1cfaca88-a219-d057-3ab8-37fb1c1687d6@ghiti.fr>
 <f7c94eb5-d496-7e24-d44f-17eaff287012@ghiti.fr>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <0d3de196-bd71-3ec9-00cd-f8274c9c5f53@oracle.com>
Date: Fri, 1 Mar 2019 09:51:50 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <f7c94eb5-d496-7e24-d44f-17eaff287012@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9182 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903010124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/1/19 5:21 AM, Alexandre Ghiti wrote:
> On 03/01/2019 07:25 AM, Alex Ghiti wrote:
>> On 2/28/19 5:26 PM, Mike Kravetz wrote:
>>> On 2/28/19 12:23 PM, Dave Hansen wrote:
>>>> On 2/28/19 11:50 AM, Mike Kravetz wrote:
>>>>> On 2/28/19 11:13 AM, Dave Hansen wrote:
>>>>>>> +    if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
>>>>>>> +        spin_lock(&hugetlb_lock);
>>>>>>> +        if (count > persistent_huge_pages(h)) {
>>>>>>> +            spin_unlock(&hugetlb_lock);
>>>>>>> +            return -EINVAL;
>>>>>>> +        }
>>>>>>> +        goto decrease_pool;
>>>>>>> +    }
>>>>>> This choice confuses me.  The "Decrease the pool size" code already
>>>>>> works and the code just falls through to it after skipping all the
>>>>>> "Increase the pool size" code.
>>>>>>
>>>>>> Why did did you need to add this case so early?  Why not just let it
>>>>>> fall through like before?
>>>>> I assume you are questioning the goto, right?  You are correct in that
>>>>> it is unnecessary and we could just fall through.
>>>> Yeah, it just looked odd to me.
> 
>> I'd rather avoid useless checks when we already know they won't
>> be met and I think that makes the code more understandable.
>>
>> But that's up to you for the next version.

I too find some value in the goto.  It tells me this !CONFIG_CONTIG_ALLOC
case is special and we are skipping the normal checks.  But, removing the
goto is not a requirement for me.

>>>>> However, I wonder if we might want to consider a wacky condition that the
>>>>> above check would prevent.  Consider a system/configuration with 5 gigantic
...
>>
>> If I may, I think that this is the kind of info the user wants to have and we should
>> return an error when it is not possible to allocate runtime huge pages.
>> I already noticed that if someone asks for 10 huge pages, and only 5 are allocated,
>> no error is returned to the user and I found that surprising.

Upon further thought, let's not consider this wacky permanent -> surplus ->
permanent case.  I just can't see it being an actual use case.

IIUC, that 'no error' behavior is somewhat expected.  I seem to recall previous
discussions about changing with the end result to leave as is.

>>>> @@ -2428,7 +2442,9 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
>>>>       } else
>>>>           nodes_allowed = &node_states[N_MEMORY];
>>>>   -    h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
>>>> +    err = set_max_huge_pages(h, count, nodes_allowed);
>>>> +    if (err)
>>>> +        goto out;
>>>>         if (nodes_allowed != &node_states[N_MEMORY])
>>>>           NODEMASK_FREE(nodes_allowed);
>>> Do note that I beleive there is a bug the above change.  The code after
>>> the out label is:
>>>
>>> out:
>>>          NODEMASK_FREE(nodes_allowed);
>>>          return err;
>>> }
>>>
>>> With the new goto, we need the same
>>> if (nodes_allowed != &node_states[N_MEMORY]) before NODEMASK_FREE().
>>>
>>> Sorry, I missed this in previous versions.
>>
>> Oh right, I'm really sorry I missed that, thank you for noticing.

This is the only issue I have with the code in hugetlb.c.  For me, the
goto can stay or go.  End result is the same.
-- 
Mike Kravetz

