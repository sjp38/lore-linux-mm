Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 780A3C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 267492182B
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:11:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 267492182B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEEBF6B0006; Fri,  2 Aug 2019 08:11:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA04E6B0008; Fri,  2 Aug 2019 08:11:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9DC166B000A; Fri,  2 Aug 2019 08:11:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 676DC6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 08:11:13 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h3so47309564pgc.19
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 05:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:thread-topic
         :content-transfer-encoding;
        bh=WaJYBwV0sp0Wd+zWm5bMV+NEQOJbB9hL4mapEey/vCY=;
        b=bO3eisrPIeMbGmXEu36/tfLbvzO0zJ7tT/Pyar0cYx8ORiZr6NqssDFdiHwNlHQukK
         MfLKCoKjiKGkEgRLqyyMJYlVDZ2irfaSw5jBTnK0ItObD0BPWg/3QrwcjNdUNA05/xvx
         sPQAPfFHSJkNd1neoqzY2wcvpW2gxLo09Pp/uvmKEqOmQiztQIWLq4j+s43Wvrqzq2Ek
         f8vFd2xDUdQENWAgyDrZT/cmOeqHjqYoBhqkzlGCT0mX8hzw51Q876gUeGmMHOox7e0h
         nZtJVCnhyGZEEi3Oep2jiZ2oORATFbJEZZn5WVM00x818pCtsO1+vtSn+vKgRVd/mWpS
         zFNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVgbbSv2sXKhRQeXBcjs+jXK0hiSHHVIyGEp16wxDcYgT9MNkuE
	GXpvpr/kFws08sc1ButQsch7jozti4axlyaCVhLFkV+Mm138+ExXvh/MPX9eYFQs6TFFIn4katL
	v0DqUesb7PJg7ODZGldtHX4LPqRp0jbwBG2ltEv+Npxh4M2X16U7an25pX+Yl2nZsKQ==
X-Received: by 2002:aa7:8392:: with SMTP id u18mr59765710pfm.72.1564747873106;
        Fri, 02 Aug 2019 05:11:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyR8CYBv6jMOd6SShyOQWavepRrMsAHDJp9QTbNEMSfAzg0/gHm5/KFEUFVAh/FQrAdKS/D
X-Received: by 2002:aa7:8392:: with SMTP id u18mr59765661pfm.72.1564747872438;
        Fri, 02 Aug 2019 05:11:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564747872; cv=none;
        d=google.com; s=arc-20160816;
        b=ztDrGvg/UnOmv8x5qPkKDOCSeGOt6FQNg5cZ/wgBu9VBWKJjO4m2bsNYGOhTjEbYP0
         aERs7z0w0kRsg2OghY6qfEs6Vk7uLVtUL4FW/YGBlXS532QrSGv0abztLow5mJXPPLyZ
         eotDxyZiiixTVqsIBPlEzlHKfJ+ShfCzK0vZXbnGl1h9rLV+Tv2zlA2w88Od4IHKm8oC
         KkUA4Zp4YNNorvy3wfEx206QVQbhe4ItoY03BROgB72zrAPBTYsVQdr8hmM2iYTCm8U8
         1eddQBSVeQZdligihVM6pwNQz1rDzz7ae6xKedyTa07dTYO1NSE1Y9UNDZYEtz3sEkzh
         4G/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:thread-topic:mime-version:message-id:date
         :subject:cc:to:from;
        bh=WaJYBwV0sp0Wd+zWm5bMV+NEQOJbB9hL4mapEey/vCY=;
        b=RJHJSHWeNPWRiNTSGReiM/oJIhCZnEwPUzXDSyRvkKZDAnuX6XRB1hdRjqQUa3YaYi
         5jyP2lTo5VaubBU6XIkkgKsLJjMPcrdb52FkPgdXG5wOop6JqjQYTNCHE4ATHiXzUwsB
         sBUKjfeuImZWvDhj89LhHFkQi4KStQ4gMOwKsbaa+gjf8MZOYKbTJVtvR5lfzeGAF+h5
         uyHbu9XZtlQpgx/vlIjhSMtGFwJ45QR/N/nH57dptGwQTOc43Q8dtlW6uM7hpRIUtrqN
         dxOX1YA9RnZ2FQ1kMJv81bagalKLzfGWWrZC+AVQCEooo/Cmb7WVHC3Wyhzdg/40SNuu
         5Ikw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail3-164.sinamail.sina.com.cn (mail3-164.sinamail.sina.com.cn. [202.108.3.164])
        by mx.google.com with SMTP id h32si36273231pld.402.2019.08.02.05.11.11
        for <linux-mm@kvack.org>;
        Fri, 02 Aug 2019 05:11:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) client-ip=202.108.3.164;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.3.164 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([124.64.0.239])
	by sina.com with ESMTP
	id 5D44285C00004AC2; Fri, 2 Aug 2019 20:11:10 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 56617130409264
From: Hillf Danton <hdanton@sina.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Masoud Sharbiani <msharbiani@apple.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Date: Fri,  2 Aug 2019 20:10:58 +0800
Message-Id: <20190802121059.13192-1-hdanton@sina.com>
MIME-Version: 1.0
Thread-Topic: Re: Possible mem cgroup bug in kernels between 4.18.0 and 5.3-rc1.
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 2 Aug 2019 16:18:40 +0800 Michal Hocko wrote:
>
> [Hillf, your email client or workflow mangles emails. In this case you
> are seem to be reusing the message id from the email you are replying to
> which confuses my email client to assume your email is a duplicate.]

[Hi Michal, I sent the previous mail with

	Message-id: <7EE30F16-A90B-47DC-A065-3C21881CD1CC@apple.com>

using git send-email after quitting vi. That tag is removed from this
message and get me informed if it makes your mail client happy.]
>
> Huh, what? You are effectively saying that we should fail the charge
> when the requested nr_pages would fit in. This doesn't make much sense
> to me. What are you trying to achive here?

The report looks like the result of a tight loop.
I want to break it and make the end result of do_page_fault unsuccessful
if nr_retries rounds of page reclaiming fail to get work done. What made
me a bit over stretched is how to determine if the chargee is a memhog
in memcg's vocabulary.
What I prefer here is that do_page_fault succeeds, even if the chargee
exhausts its memory quota/budget granted, as long as more than nr_pages
can be reclaimed _within_ nr_retries rounds. IOW the deadline for memhog
is nr_retries, and no more.

Thanks
Hillf

