Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 120CDC5B578
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB253206A2
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 03:16:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Pot1G5l2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB253206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BD0C6B0006; Mon,  1 Jul 2019 23:16:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46E898E0003; Mon,  1 Jul 2019 23:16:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 334B18E0002; Mon,  1 Jul 2019 23:16:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1639C6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 23:16:04 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n8so17239787ioo.21
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 20:16:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=g2v0mtMOM4iBYII4Lvz5GUbGDJjPR4J5yr7i/lhr77c=;
        b=apTb5Qqr3zzTf11ROj3wmlsZm+Pdo+Ss8h1lKHEKfe75eu0RHb0rhl5Vl6ovyN/Kbj
         mbEiKxTzgKa+qFxxrseHl49gMHcmmjyONuw+9/lekognPzWrXmNZMmKVSerpBzNPvlUz
         4/7OqH64RNVBM5erFUws5yLAkvAXMVSSPAIViSQ9v30s8vsR2tx4cyDhWbseQ3wIeNt8
         0eHuHkfoxAY+A8EgGQKkPleOg2QjMxGQuZKP6CIo/ioz0QdHUy2OGpmWVk+wid9Kl69R
         ieBmpuFhTK2QKjZViBWqupOg0JC2ipj+MyypmlM5nB8msB1TOA4eE/flJ2G2ThAsTwKY
         yWGA==
X-Gm-Message-State: APjAAAVOot6Ees5uTA3F7UgO5i2xcfFKkKKl27ygUv6LZJxX0Gpun0bA
	OhTvDYOXZDeWKJlzzAgtAgHCnkUxwrP4VtGoeZZukU6XEFTHjcV0hHvCD1VYcUCDkmyE3ZiIbAF
	TDQSUXJwWLKqfz/VOvgqRzBIaNWHywP0Ep9R9/8BWrV34hTlFrjCumwdCzRvxsxBCcg==
X-Received: by 2002:a02:ac09:: with SMTP id a9mr33904461jao.48.1562037363844;
        Mon, 01 Jul 2019 20:16:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkPnMKxBt3Kgc2zayLDs+btYRlt+MLZbv6bm4CrNk9kMvBB4fk4s1fmT9r63X+UvhHYPi+
X-Received: by 2002:a02:ac09:: with SMTP id a9mr33904415jao.48.1562037363065;
        Mon, 01 Jul 2019 20:16:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562037363; cv=none;
        d=google.com; s=arc-20160816;
        b=sMGxyG5OYxq6xqRs2R65gb/kzp+0OaSsPMOwUKvlwOWE3GfVhimII7xEune0dKhKY/
         3nuxH7+Af3KyCk4oCdXcqQr3Qt7prQZbwmB253NNM5ph5jnnJYsMW9SRRQa0Ak/OStcF
         wm5bi9HP+ZpL2iHz/DGupOhjqZMvZ29tDgr38fnSiNTWpoyYAjMDIEuDlCyUywzhIdIr
         Q1sjZzVs/wLFKcAHY6AhOH1Hkdu/D4q6MsSPltlvzoutU5qIyERtYAxIBCz1kyTd4Pbp
         6oEuEod9n/o7/d7qXOi/1mfIh2CyCKIaiBoUdW/okxzSDb0RfTPrTHp08a3H/o5vjn8x
         nt7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=g2v0mtMOM4iBYII4Lvz5GUbGDJjPR4J5yr7i/lhr77c=;
        b=T+FzT8Swwafgr5wD3ob+wsfK+ql/0OpqnBrwBIuRIwW3eufiGUwZ4gI0nM35toyBj0
         junJR2K9wUTSgIZ0BLsAQAsMTE5IJn5RjHBdCf0lzL7+40LjYFD5+jIwYVhq8qMMnGXm
         Vs+5tUBwMG7k49C+CoCGangIcb2sccPqo74Z2MNZ0+MEsDWr/Yp7PIPaCfbs0j1Sg85U
         o2qg8Ecpgd0OSEu+3JS7paEL2JEkxevOEPSw0m5jYo0O51FkfHOAn3xpqtOUzio/lFed
         DtDyT9tK6MTmY3qFWRp+ygmY37SavcFkeUVqrwjPK7XZRvvd0gN+vpNTdwvBwsHRapkY
         45vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Pot1G5l2;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id g2si21826125jar.3.2019.07.01.20.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 20:16:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Pot1G5l2;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6234unt139052;
	Tue, 2 Jul 2019 03:16:00 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=g2v0mtMOM4iBYII4Lvz5GUbGDJjPR4J5yr7i/lhr77c=;
 b=Pot1G5l2XAak+Hb7v+Jl5K4MzggYiIz9mI+CQPxrjAzFW8MgddIWMfHjKcCsmcxBAQg6
 nVTqHdjP8y89kn5u/N0GVR9MRk8c1DsL9VYahZTx119DrG6y6DDpA7F3RnNaVacED521
 IJkowT/bgcO3cbr0KwJOv3V3EeUxBBy1lKSaVqjmqgh7Q9226npgLAVEiwoa6v4yaTzE
 o4eWQfbPHC33Up22Jm3wGfCpyBElE+qacOWPbym7HkiU9a8zoNwX2gERtthA57NJSEks
 XelHk+sQ59mpvYE4n2beYlnb+qhvP/XzSFLCAMD7+kmj5Xbh2OY2x96u4ZEzHCRytZ5q HQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2te5tbgu8s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Jul 2019 03:16:00 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6238LHV178941;
	Tue, 2 Jul 2019 03:15:59 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2tebqg8hsq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Jul 2019 03:15:59 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x623Fp7w025613;
	Tue, 2 Jul 2019 03:15:51 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 01 Jul 2019 20:15:51 -0700
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        Johannes Weiner <hannes@cmpxchg.org>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
 <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
 <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>
 <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com>
 <20190701085920.GB2812@suse.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
Date: Mon, 1 Jul 2019 20:15:50 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190701085920.GB2812@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9305 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907020032
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9305 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907020032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/1/19 1:59 AM, Mel Gorman wrote:
> On Fri, Jun 28, 2019 at 11:20:42AM -0700, Mike Kravetz wrote:
>> On 4/24/19 7:35 AM, Vlastimil Babka wrote:
>>> On 4/23/19 6:39 PM, Mike Kravetz wrote:
>>>>> That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
>>>>> looks like there is something wrong in the reclaim going on.
>>>>
>>>> Ok, I will start digging into that.  Just wanted to make sure before I got
>>>> into it too deep.
>>>>
>>>> BTW - This is very easy to reproduce.  Just try to allocate more huge pages
>>>> than will fit into memory.  I see this 'reclaim taking forever' behavior on
>>>> v5.1-rc5-mmotm-2019-04-19-14-53.  Looks like it was there in v5.0 as well.
>>>
>>> I'd suspect this in should_continue_reclaim():
>>>
>>>         /* Consider stopping depending on scan and reclaim activity */
>>>         if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
>>>                 /*
>>>                  * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
>>>                  * full LRU list has been scanned and we are still failing
>>>                  * to reclaim pages. This full LRU scan is potentially
>>>                  * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
>>>                  */
>>>                 if (!nr_reclaimed && !nr_scanned)
>>>                         return false;
>>>
>>> And that for some reason, nr_scanned never becomes zero. But it's hard
>>> to figure out through all the layers of functions :/
>>
>> I got back to looking into the direct reclaim/compaction stalls when
>> trying to allocate huge pages.  As previously mentioned, the code is
>> looping for a long time in shrink_node().  The routine
>> should_continue_reclaim() returns true perhaps more often than it should.
>>
>> As Vlastmil guessed, my debug code output below shows nr_scanned is remaining
>> non-zero for quite a while.  This was on v5.2-rc6.
>>
> 
> I think it would be reasonable to have should_continue_reclaim allow an
> exit if scanning at higher priority than DEF_PRIORITY - 2, nr_scanned is
> less than SWAP_CLUSTER_MAX and no pages are being reclaimed.

Thanks Mel,

I added such a check to should_continue_reclaim.  However, it does not
address the issue I am seeing.  In that do-while loop in shrink_node,
the scan priority is not raised (priority--).  We can enter the loop
with priority == DEF_PRIORITY and continue to loop for minutes as seen
in my previous debug output.

-- 
Mike Kravetz

