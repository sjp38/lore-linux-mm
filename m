Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 072EAC46470
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:07:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C494C2053B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C494C2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60E1C6B026F; Mon,  6 May 2019 15:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BE136B0273; Mon,  6 May 2019 15:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 486966B0274; Mon,  6 May 2019 15:07:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F70D6B026F
	for <linux-mm@kvack.org>; Mon,  6 May 2019 15:07:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n52so12846124edd.2
        for <linux-mm@kvack.org>; Mon, 06 May 2019 12:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lAzmpx4FNwPR3u4ivk6x/Z+Ho7uREn+up87ZB/iWedg=;
        b=rzwlm7QvsUjkF/EYf+sxtmgUFVlMDs0T3ODvNu8p16adypGb3rV6dO+ryQrpSnO/ew
         i6BjWAXqFKIhBQnjJyIFd/BNtjsDtYx5UOeliJVtmuHYN7HgmbXIMikr9dhFoPMM6mVL
         psaNZekXp1rvKLX27Z9KsjkdnaOZTQGAoOt11pZiPyUa0C6vLOG6ayjCtiBmkThpsgxn
         cBIdJelPZeW8jlPDUiK3CHmmbk4ck5GY+Tdka0cIrrt+hyh40QT5ZhMBw5c0dRJIY3T0
         NpJpJgK1b/YidExytO8fzn7OGt5bEig5N5DgsBQer7stECROAqtaH+3g/bQPPG7kLIdF
         GIzw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUeon4cW8RIjIIGIXGa47lpQ2DpoAtqj7jGvFNPEKu+6bdTzifG
	aBljRQKLOzQf8iFKLi2da6ir1a3SS9pOmfrsm++asWAGrSTkYlM23kFKCx0b3ga2jcmc1SmtGO+
	LR74CocFWVFjJ3Q1y95vH75DGfGAN3FDn62ZblDl1lca9EiC3wo0gCUOaQflOkMw=
X-Received: by 2002:a50:b69c:: with SMTP id d28mr26713319ede.129.1557169654649;
        Mon, 06 May 2019 12:07:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQG+pYjDJ9yHZCg8BKUYUm7jiK13vYjTo3u3fawTEIcVGXv9hZqAwf9coZK+ZMCSbh36P/
X-Received: by 2002:a50:b69c:: with SMTP id d28mr26713245ede.129.1557169653921;
        Mon, 06 May 2019 12:07:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557169653; cv=none;
        d=google.com; s=arc-20160816;
        b=OV2Pi2+qXp40oGusXGGm5goyryf9tnzu4AeC33ap4Amsbple3BeIdKfYwI70oi/Dol
         TuEInmO6RtXQxmdUBCn5VLifqCk/rpEDbVqu9PtHJgO9nLiMXHXjSrPevZHoBAVb1pLS
         qYdMDFG0Zi4DhB7t8yYMEgdnfGdyL0qeVjwdPMz9WtH4L2rM+IAZ0YFU47zcbJO9jM2J
         0ExlheOIDVU0tqSdqudFeBD3VHABg2DtazAHvzqZL2hsz14uRPhwjEdJGMXrLoauNce+
         AG5B26qwvs6N4OX+flraMouzWEtQsl4QnaGcNXh+5v4FVxKPN9v5X45T6T2wtsqxUFTk
         EeGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lAzmpx4FNwPR3u4ivk6x/Z+Ho7uREn+up87ZB/iWedg=;
        b=mBasymxj30y6FMeenylMndNfowbzSrlbcQpcX7XSYKmqnysnj7hOeoHypfzSONjoQN
         XYu2tcuW9m3NCrXBzNI5LfbnyGXib7WFVyR+z7haSbLpfTHYMGZ4hn3tldaBWA8BdkBd
         YXV/VBx0/1I/2jq2YJRtp0GclJvNr0YvOlaM1mbp3+DVibJvFEd/9wcb13Qqnx5tupU0
         7M6azMLotj40EHsX6NQ0jaRFKKP8YqGZ1RY93911zItzJqPuTGoVHK6mo+CzhjWTMl52
         yclBiG4yWzMWi9eZETiJ4QFQnXgZFblyZ19YihAz6idwHkbR2ZO1cbnXEBvdBNOOyVz7
         lUIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h53si2385223edh.411.2019.05.06.12.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 12:07:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F2707AD3A;
	Mon,  6 May 2019 19:07:32 +0000 (UTC)
Date: Mon, 6 May 2019 21:07:31 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Zhiqiang Liu <liuzhiqiang26@huawei.com>
Cc: mike.kravetz@oracle.com, shenkai8@huawei.com, linfeilong@huawei.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	wangwang2@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>,
	Mingfangsen <mingfangsen@huawei.com>, agl@us.ibm.com,
	nacc@us.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
Message-ID: <20190506190731.GE31017@dhcp22.suse.cz>
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
 <20190506142001.GC31017@dhcp22.suse.cz>
 <d11fa51f-e976-ec33-4f5b-3b26ada64306@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d11fa51f-e976-ec33-4f5b-3b26ada64306@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 06-05-19 23:22:08, Zhiqiang Liu wrote:
[...]
> Does adding Cc: stable mean adding Cc: <stable@vger.kernel.org>
> tag in the patch or Ccing stable@vger.kernel.org when sending the new mail?

The former. See Documentation/process/stable-kernel-rules.rst for more.

Thanks!
-- 
Michal Hocko
SUSE Labs

