Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0760C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:50:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 676652171F
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:50:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DdAorvBu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 676652171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 024576B0003; Mon, 20 May 2019 21:50:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F193E6B0005; Mon, 20 May 2019 21:50:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDF866B0006; Mon, 20 May 2019 21:50:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE9426B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:50:12 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id o83so1234637itc.9
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:50:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=dn+YYBqV56XU7F7c8CWuso5/+bxKEcmadpFPiXvJSds=;
        b=pDicNOOl+jFEsnd9+ISqDQcQsmIZczstFOQCXaexrwOIwbBFyrn05H1h4pRm7aYqE1
         842ei96cQY1Z2DfpyxJss3yFdcRMazCYcylk5qs7eoquWrxRwLq+qoTgzIM20VQAjIT+
         g94sZzUBFKnSdvlPpzwilzo7GdXVOOUsb5MhEw/u+QcCh0Gudei70RDW3UomkD7v0bno
         Yaga6r/kte6XrMI67UgfJ1IC0pQFzdaYlVQ0YYgZThrSFLD1r5D94o8y1XK+Nlzg6UV2
         YYO5EvePEs/O1G4FzIIsvIT/5lRcTTjDudkXhrWA+cRCiNsoP+kmoZK4uyP3MOwzzov4
         P1KA==
X-Gm-Message-State: APjAAAVtnaCRLAteIpbctrw60tKNteWxAdD/pYo+jmme0o9JVVsVweKv
	T99kRCUav+SJkso7HbjMpX+6gd52XaDIUgjKSpuBtvzLlcr9sfay4FKLMFUIb74dTS3wRuRl/yT
	4r1U2cTS/ymu9y+7lsqhOVnIHYczimobz4NgTc9koteoBd+XEjJlZFsG+0iYFzj2qmA==
X-Received: by 2002:a24:cec3:: with SMTP id v186mr1822615itg.173.1558403412469;
        Mon, 20 May 2019 18:50:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8VJ5OrXm8+Y13gtocYyf7+SbnbTuD8Uy1HxfuUiIvV2D22X3GzyONBtctnOKdlXOz1clC
X-Received: by 2002:a24:cec3:: with SMTP id v186mr1822582itg.173.1558403411700;
        Mon, 20 May 2019 18:50:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403411; cv=none;
        d=google.com; s=arc-20160816;
        b=M61kzsHRzEj+Kd2Lr6NvRGgsIJbSVMu9WiZQdmLI85Xfn0iPmTkVJccCPrOTgdU3eh
         zjYXzyDCUWsIH2RU0f1P9l1jcM5GngRILjUQT7iouZNpfqrM3tpqgaU3f2ieNjwVDfVN
         FAuLEpQUfk0yoDMzmwQwEHZ1V9t4ZK1HxqA0JQZt3i0YZojx3F71ezgAxkgiGxUCibxn
         2CJe0PhAD8ZUePa0J7uZ5mEVGLVM91BBZUjgwZa0nKapCasHZnl6SVUfvYJi1qB0lGHi
         cYM33B4mJC17NLow2nx4l+pQgLhWwSjbZhjO8vCocpnG07A576wYpel8SY5uqL6PAEn2
         mpXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=dn+YYBqV56XU7F7c8CWuso5/+bxKEcmadpFPiXvJSds=;
        b=NVv1MRU6ndxIOG/95ENVZnTop44TcZAv0fA+W5trQNEMwvF+W7MdaX+t/09k8kPHfi
         s/8IYHyXf2SzbbP/DoFAw6OTK/mRA1QVHqbWordfleM24XRmR3RnjloBcPCLGPf2X5+p
         pJEkeJBagkFDt7OEU873qDG20ixQ9lbEkBXnGZqEAAi5PnNb3sRSkdMytGI33Y/kzHww
         PnL6yGEtmo1o0hzeBslhPXUIQ750W68+xPDruJqTXsOT3Of5PYtJFiT5EtkYbJ8z6Zag
         ODr8L+saYzf4exzmusWlCjwmAZowa28mdHw8DH//7rPI2QkjwyXk0iHC1biGhI1E9S0D
         kCZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DdAorvBu;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 138si995370itl.43.2019.05.20.18.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 18:50:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DdAorvBu;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4L1nFqj053277;
	Tue, 21 May 2019 01:50:06 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=dn+YYBqV56XU7F7c8CWuso5/+bxKEcmadpFPiXvJSds=;
 b=DdAorvBuJ54owqKG0kLG39NVx7aA0pnGQwqww2td+q3Q1tnyKKa/wLEQXTY+tsG2Te1d
 v3vE+2FjpNDnS77mfNnXh6YQrMpVPdIL7n6fpi4uJiroTlDpFR7MxG8tC55LHMiaw+5Y
 ReeZzbIVqmHfkYSiyZp86cOiDHWGhSRMMBqUqkqed1VfAde28N0s4YUo0tvaSys4mvBM
 0XigivNYS6TCuK6bakIVbsIkeTpREeiZfg103SbG9xE2gS1LMT2pHQlI+nUBSxbywcpN
 8n2ukoqn5/SEAUsMPplFXfogsWXKud+1bO0wbsQUQ6haFsLfiPuSsLGADUM71mZ7jROQ Kw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2sjapqa6sr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 01:50:05 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4L1nYqf031921;
	Tue, 21 May 2019 01:50:05 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2sks1xww56-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 01:50:04 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4L1o4tS000757;
	Tue, 21 May 2019 01:50:04 GMT
Received: from [10.159.155.76] (/10.159.155.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 21 May 2019 01:50:04 +0000
Subject: Re: [PATCH] mm, memory-failure: clarify error message
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
References: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
 <512532de-4c09-626d-380f-58cef519166b@arm.com>
 <20190520102106.GA12721@hori.linux.bs1.fc.nec.co.jp>
From: Jane Chu <jane.chu@oracle.com>
Organization: Oracle Corporation
Message-ID: <49fd8918-5762-9b92-d383-8fdd96cf1c38@oracle.com>
Date: Mon, 20 May 2019 18:50:02 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190520102106.GA12721@hori.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9263 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905210009
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9263 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905210009
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks Vishal and Naoya!

-jane

On 5/20/2019 3:21 AM, Naoya Horiguchi wrote:
> On Fri, May 17, 2019 at 10:18:02AM +0530, Anshuman Khandual wrote:
>>
>> On 05/17/2019 09:38 AM, Jane Chu wrote:
>>> Some user who install SIGBUS handler that does longjmp out
>> What the longjmp about ? Are you referring to the mechanism of catching the
>> signal which was registered ?
> AFAIK, longjmp() might be useful for signal-based retrying, so highly
> optimized applications like Oracle DB might want to utilize it to handle
> memory errors in application level, I guess.
>
>>> therefore keeping the process alive is confused by the error
>>> message
>>>    "[188988.765862] Memory failure: 0x1840200: Killing
>>>     cellsrv:33395 due to hardware memory corruption"
>> Its a valid point because those are two distinct actions.
>>
>>> Slightly modify the error message to improve clarity.
>>>
>>> Signed-off-by: Jane Chu <jane.chu@oracle.com>
>>> ---
>>>   mm/memory-failure.c | 7 ++++---
>>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>>> index fc8b517..14de5e2 100644
>>> --- a/mm/memory-failure.c
>>> +++ b/mm/memory-failure.c
>>> @@ -216,10 +216,9 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
>>>   	short addr_lsb = tk->size_shift;
>>>   	int ret;
>>>   
>>> -	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
>>> -		pfn, t->comm, t->pid);
>>> -
>>>   	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
>>> +		pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory "
>>> +			"corruption\n", pfn, t->comm, t->pid);
>>>   		ret = force_sig_mceerr(BUS_MCEERR_AR, (void __user *)tk->addr,
>>>   				       addr_lsb, current);
>>>   	} else {
>>> @@ -229,6 +228,8 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
>>>   		 * This could cause a loop when the user sets SIGBUS
>>>   		 * to SIG_IGN, but hopefully no one will do that?
>>>   		 */
>>> +		pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware "
>>> +			"memory corruption\n", pfn, t->comm, t->pid);
>>>   		ret = send_sig_mceerr(BUS_MCEERR_AO, (void __user *)tk->addr,
>>>   				      addr_lsb, t);  /* synchronous? */
>> As both the pr_err() messages are very similar, could not we just switch between "Killing"
>> and "Sending SIGBUS to" based on a variable e.g action_[kill|sigbus] evaluated previously
>> with ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm).
> That might need additional if sentence, which I'm not sure worth doing.
> I think that the simplest fix for the reported problem (a confusing message)
> is like below:
>
> 	-	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
> 	+	pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware memory corruption\n",
> 			pfn, t->comm, t->pid);
>
> Or, if we have a good reason to separate the message for MF_ACTION_REQUIRED and
> MF_ACTION_OPTIONAL, that might be OK.
>
> Thanks,
> Naoya Horiguchi

