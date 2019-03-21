Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DF74C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 22:01:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 45E4A21917
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 22:01:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 45E4A21917
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED86B6B0006; Thu, 21 Mar 2019 18:01:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAF036B0007; Thu, 21 Mar 2019 18:01:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9FA56B0008; Thu, 21 Mar 2019 18:01:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 981676B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 18:01:09 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m17so187105pgk.3
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 15:01:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=75wXbI6fqRaqYr1j6d3FptNQOdk6OKV3h4rajfKqpEk=;
        b=PqYUn69G+Qxkg/WVaA9kiYFED27lHJ1M8hqaBKEwISGV4edIo2PYD8OHSmQeRl7m/E
         ZDC1xTZCG5qrwRS2Wt9y+U3+D10KosSBZG72BE6fXg/WneuqTYs51wKmF0U/uzrSFGwc
         1envETWbxLAnm/F/ujajVvLogqBB+4zOLXFMwswKKtq6wP4uV9IVR7sK6j6Lf7r571xy
         vlRtjvyQb1H5W+tZ6ee1Mtv9HCRr1AZYTqiCBQroDiWUha0Ta+bH4EdEIjniLMhTyVDe
         IDe2X9fkpMj1xPWDb5VDxxEmLRD+DStJzV1xmQFzxwdGED8sWCvTwYMPqNoMFVSH4kbI
         Dq8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWXnW3vOJLhO1HRFfqmzd+c2TSxBW5FZjN3pRCgyyvc1h1tJLrh
	kvLdDjCGm/HT1RzPwxM/KO2EMH28ThIU+4Chy4zTQnE1bZC8B5c9wwiN2mHuuO4rUkUn6Z8B+BC
	fS+W5AH40gAHT2Hco4+lypKllmIfR/5j9fSxi5e0A4woHIDDkK54Pmd5HfoFxvap+vQ==
X-Received: by 2002:a63:544f:: with SMTP id e15mr5628540pgm.344.1553205669299;
        Thu, 21 Mar 2019 15:01:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOZmMpfnbZ9QAlpLLLD5ebZhPyjja5v1d1Maqhm4mSHdcvLI4Pzc8EGnLH7NcmDKMzHzjG
X-Received: by 2002:a63:544f:: with SMTP id e15mr5628464pgm.344.1553205668448;
        Thu, 21 Mar 2019 15:01:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553205668; cv=none;
        d=google.com; s=arc-20160816;
        b=jQZPzBpD1qHYjRVA3t0s+yUcdq3KFuNK3v9H/TrCN7TcPdKXqruRwG7Rfc53JOojM7
         ve6RhMFT2OR1XtruTBwXuSuXQXe4GMaDdNOIY54DGsgRR6RCNBh1Kq9ZLDRY/W4gzW79
         kTaEbFkC+Yk8LKgLuKnVVhlHmwnHQe5nk/eeLzFNlKl0h8OetuxHv6OYRh+00kO5qbE4
         r33OhPEZVeZQPaLCh65M5VNn+dEw1fnWr7CvhRcHWQwkTmpaeaLZNJ08EzSIUX5F2j8c
         IaIgF5/K8XLxhfW+oOkkEvqlGJaBn/QwZiMjo/EX23XAH2Q7VnM+OcM8HwWA9/w4mVAz
         K4ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=75wXbI6fqRaqYr1j6d3FptNQOdk6OKV3h4rajfKqpEk=;
        b=gz3jzoaTsymiHy0wznE623MZUY2Mtsejt7sajpNl4ESDWMHAE78haKALCd6D8XUfcf
         xY/B0IiuW/83gz8sTxKQoAOgjxyKsuHxs/zWybggZN5bOuQvY3D5KGWehSKSX9gOGTKE
         AvFV5bICN21BPjw+5O1qnzCJl482TY/nvhxs2VfTkImSlWxHXN1Szbyf6lbCw2ivVx2U
         SaU8jNKwZZhNK0T3CPZ7k0etiNIl+e2A80XliyRsYQekPSrUUo+QxadBCfZD6QRJkEG1
         lL3PyVRtUWP9H7QJw9rwnWzEe2HxgPtWmIEsEH5SIOosgbZhDv9dstqfN8G+YVJfQnF8
         IDlw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t5si5004054pgu.517.2019.03.21.15.01.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 15:01:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 9F11EEF1;
	Thu, 21 Mar 2019 22:01:07 +0000 (UTC)
Date: Thu, 21 Mar 2019 15:01:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>,
 linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Thomas Garnier
 <thgarnie@google.com>, Oleksiy Avramchenko
 <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>,
 Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 0/1] improve vmap allocation
Message-Id: <20190321150106.198f70e1e949e2cb8cc06f1c@linux-foundation.org>
In-Reply-To: <20190321190327.11813-1-urezki@gmail.com>
References: <20190321190327.11813-1-urezki@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019 20:03:26 +0100 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> Hello.
> 
> This is the v2 of the https://lkml.org/lkml/2018/10/19/786 rework. Instead of
> referring you to that link, i will go through it again describing the improved
> allocation method and provide changes between v1 and v2 in the end.
> 
> ...
>

> Performance analysis
> --------------------

Impressive numbers.  But this is presumably a worst-case microbenchmark.

Are you able to describe the benefits which are observed in some
real-world workload which someone cares about?

It's a lot of new code. I t looks decent and I'll toss it in there for
further testing.  Hopefully someone will be able to find the time for a
detailed review.

Trivial point: the code uses "inline" a lot.  Nowadays gcc cheerfully
ignores that and does its own thing.  You might want to look at the
effects of simply deleting all that.  Is the generated code better or
worse or the same?  If something really needs to be inlined then use
__always_inline, preferably with a comment explaining why it is there.

