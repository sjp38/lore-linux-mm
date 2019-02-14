Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5FD9C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:19:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B1CF222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 10:19:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B1CF222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14BF18E0002; Thu, 14 Feb 2019 05:19:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FC938E0001; Thu, 14 Feb 2019 05:19:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 012CB8E0002; Thu, 14 Feb 2019 05:19:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id A4D8B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 05:19:37 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id x18-v6so1478218lji.0
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 02:19:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=+4ve8CAdHtynStprXBXLuBkZ7uLxFl9x1SCvICoJcmM=;
        b=q/ifM035PrACLsq5fFV8iEXqOiJk7kQQW5jOJbhWcMUKhxlryg7kOaPnCbfIe6WVsv
         9rFz3U/BQmRNxR3enpkdG9FXSUByxJRSOFOAt65yuB1H7CmFNJ/4gV61svIjQqAF4zpT
         ccRTSw2WwcsZwGqrmjWc7esJ7029QCW8bEG+CzxhJ5cPAsckk99cGL1shwTKE1NsMOCV
         csCVCHKzORPkFxUlDmfNFaers1W8uobq4s3z6++BMVFcg83eLDM1TgUOe4v/1xP5D2Vt
         x3wLDYhCwnlRIgHOGmb6OltfS5Sefkxr7BAu3UbzIENt242Cox+eOS8wp9uZPDZ0Zbv7
         sppg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: AHQUAuYBc/YCstfUqPUD9CMFaIKVuJKi4iU29F9DjwQv1OE8XfStWmJP
	DUN4GHNCSFEsPOjtfw0O6YRm17dSTWkvHmBV+VzVR1++38WbQsyrOuRa7o9NlU8mNFTWK3GramY
	H425bxuJWnGfoiZ2TAZqZUJc3RECSC/cuogADdM0aJPoDD74vS9mtDeH20MGKEx27Ig==
X-Received: by 2002:a2e:5cc4:: with SMTP id q187-v6mr1651582ljb.69.1550139576886;
        Thu, 14 Feb 2019 02:19:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaJp2fKWE1dpNJKM0baM8eSSytkiz7Uu0iHQU5eAjVWyxXEG/JUZVTVQTjUI2uyB8b0sDF3
X-Received: by 2002:a2e:5cc4:: with SMTP id q187-v6mr1651535ljb.69.1550139575905;
        Thu, 14 Feb 2019 02:19:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550139575; cv=none;
        d=google.com; s=arc-20160816;
        b=GCSRHm3RhCsijG4O14sz5vn99NYhFbbCKQWeqC0pgYVx71EF35BOW7Z4a030nm2gBn
         rNttRX22uSYfHnZmvOurl/QJ1PXwV634+m8xmJU4jvvJNhSBJkAeZgUvUVhG2N5NpGPq
         Lx/YiUIZdeG4SMA6wI+MDkQga5T69RdVb+hVxGr4FuTcvOfRUxnZauXd1iWNRNnWkLM6
         hewr7sTfdqwIzoCmFDWwEbss5JKRwpZPrMFkiRMr5eb4mV0AR/UhTQ2gUL6N6+oUgpx/
         pbYURJru6zHYvJrG/WmYXSsrO49VOGY3lkUJ40qXSHFLJf1tuvei3wweCdLrDU0wicNK
         DAtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=+4ve8CAdHtynStprXBXLuBkZ7uLxFl9x1SCvICoJcmM=;
        b=eYrolkhUlsqeS27Tmc+TnB1gbeidlLheXJEOPK+VJen+MX6HKi2kwO4g61ubPDpos+
         p7Kd9Lif2eE+T/G5QKXluygPradb2xQrex5jwk4rs5mjmCqtJF2YrY8v6XVEyAAR/auh
         b0mrmDHdfqyTt+NFUP8XmNjUie7sIaENWK8WAVxpvwPz52GtQb6vN9Dms4+Y8WNHqbJA
         yefR3igrwsSyhB9rFYIWw0uEoiAAQ4JiGd05ZYmgy0P00/RyuNAkOBeHeMQx5UY3rXD9
         zYyRE33yCipNJj3VSBerYo3gP7n0g+FcL4p7GoWtjRhvg0BgEVT9W7ku1Hh52cGH0aVS
         5zWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id h11-v6si1829353ljj.57.2019.02.14.02.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 02:19:35 -0800 (PST)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1guE79-0004zP-Jo; Thu, 14 Feb 2019 13:19:31 +0300
Subject: Re: [PATCH 1/4] mm: Move recent_rotated pages calculation to
 shrink_inactive_list()
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998444053.18704.14821278988281142015.stgit@localhost.localdomain>
 <20190213173327.uhexilxmmztx7fbt@ca-dmjordan1.us.oracle.com>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <057454bf-5f49-2043-9197-68f99a0501a4@virtuozzo.com>
Date: Thu, 14 Feb 2019 13:19:30 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213173327.uhexilxmmztx7fbt@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 13.02.2019 20:33, Daniel Jordan wrote:
> On Tue, Feb 12, 2019 at 06:14:00PM +0300, Kirill Tkhai wrote:
>> Currently, struct reclaim_stat::nr_activate is a local variable,
>> used only in shrink_page_list(). This patch introduces another
>> local variable pgactivate to use instead of it, and reuses
>> nr_activate to account number of active pages.
>>
>> Note, that we need nr_activate to be an array, since type of page
>> may change during shrink_page_list() (see ClearPageSwapBacked()).
>>
>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>> ---
>>  include/linux/vmstat.h |    2 +-
>>  mm/vmscan.c            |   15 +++++++--------
> 
> include/trace/events/vmscan.h needs to account for the array-ification of
> nr_activate too.

Yeah, thanks.

