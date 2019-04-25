Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E54AAC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:00:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA41A20878
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 20:00:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA41A20878
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 468336B0003; Thu, 25 Apr 2019 16:00:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43DE46B0005; Thu, 25 Apr 2019 16:00:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3545B6B0006; Thu, 25 Apr 2019 16:00:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC996B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 16:00:17 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id j20so791417qta.23
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 13:00:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition
         :content-transfer-encoding:user-agent;
        bh=W8Jv88qOOSPoTOGfu1QmS/lZCrZdFXwsOWJ9lxWB8q4=;
        b=aLQuRkHn6ObD3/Uzcyd67yNSW/b6WgKj7rQC5qSAGNNZvQzvzJyrG2uL9qkIk7CTnz
         tTT+ABFFm17i3vQlRb4QICTF3I8v7RMlYjB4JjY7Zr+Ci2TJ/RGqkXtdoulEceOwJK45
         MHyHiqYeRwBpjrhvQGUpGqua5SycmNzraUbRHBUsvzckfzafM1zoY7z3uJ6tISViuxIH
         vc3H+dFNZAZBy6GBLSg79WnZ6gn0LUWtS56+Fj1jlIDTu/rQw76G2/sbdEWQ5pmVaiRc
         mJCgIAGiCoDsEnvAvvnMWbwRxdwgbIZv8DSykCr50yb3N2HGm/PcJ0FsZz0FUfF1aWjL
         +SYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAULeJi9ai+SWJIF/0zgZowkgo8Kdgultboyeas0vr1eml9sVQ7S
	Rs01OraFn7cRvTjTzCrRpef6NZRywIOJ69poRD1sUxEaHUygwl+nr8biYug8SIkeFa8OHrGPGqb
	PrV5TM+LW4iY0ycHytjeFg9poZ0zak4r6c/fr18rHqSIAplmaM1wUmPmGExZISOBxuQ==
X-Received: by 2002:aed:20c3:: with SMTP id 61mr31733770qtb.356.1556222416902;
        Thu, 25 Apr 2019 13:00:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydWYmghGSEvI2nWkmKHQmWulGX63OB8HZ5Uw5dNUHC3V3zABbzKLjbCMpJBWCIIJ3ukEZX
X-Received: by 2002:aed:20c3:: with SMTP id 61mr31733670qtb.356.1556222415980;
        Thu, 25 Apr 2019 13:00:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556222415; cv=none;
        d=google.com; s=arc-20160816;
        b=cWZpGxyTF3iFXHKotnXzpQFKWzKfndrXaE8iR9u4ZkvsA6PUZcIpr1jBxFsRwdkdto
         YdLbgtRu54bw36qruDmkppLT9EazCBnB9AvjvVmhYkFwInSKTVaSIJNu/nBpWaPJGJAI
         rYH4ospdFioSEKZ8vwKmTWOrBPX/fab94COWSe5z8kn22G5AkKmTN+JQCFIBGw9f5zll
         6DzY3uzNRHkyaaSDZ3aF2kjdXLmSdnfLN1nRQ6PHZUCKTOBDz+ddcRXWs9C9JxPaTyIm
         vbuPTSjLpJUK8VmOiLE31pUkc8FhdylxIgqYnqSwMelnW3Fmwu9WVEAOG5BiOONFXABV
         baFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-transfer-encoding:content-disposition
         :mime-version:message-id:subject:cc:to:from:date;
        bh=W8Jv88qOOSPoTOGfu1QmS/lZCrZdFXwsOWJ9lxWB8q4=;
        b=uNIVv5sEW/1MFfKHYCpm0uVGP7jmxW3WyMW9ZN+0EphmhJBZGnBBMAkCvqtYRgl1AH
         3hauWA0TXqzifn5YzJvIJN/XMSOOHCodXfxnwegovPhFGveW/6dfEbD2ThFBacO2RpfM
         iIwDSihQtmJmYNBxJIPVxi1BK8yjmuz3Fw+jPXP9B792lwQT3K+lAp2ruZAGs0zNWbt4
         s5d+5B7IlfpHrqvJuIEmU5DgH2H7c2fOz+KuyRSpOhx/4hQMC2JP7WRLzRaxKZKvvyqg
         m5nzvzRY7gX4tMeBs4aP2b3Y+Hq8qjdUCE+LW4JbnEcU1B47JNM+Cjdkd+dWu3EgoUuH
         0Y+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b43si2793911qta.356.2019.04.25.13.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 13:00:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DDFD58AE49;
	Thu, 25 Apr 2019 20:00:14 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2EF8A60C70;
	Thu, 25 Apr 2019 20:00:14 +0000 (UTC)
Date: Thu, 25 Apr 2019 16:00:12 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [LSF/MM] Preliminary agenda ? Anyone ... anyone ? Bueller ?
Message-ID: <20190425200012.GA6391@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 25 Apr 2019 20:00:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Did i miss preliminary agenda somewhere ? In previous year i think
there use to be one by now :)

Cheers,
Jérôme

