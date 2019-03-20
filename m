Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78BCBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:59:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35C50218B0
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:59:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="YFtoHdtQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35C50218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE9E96B0003; Wed, 20 Mar 2019 16:59:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D996B6B0006; Wed, 20 Mar 2019 16:59:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C8A0F6B0007; Wed, 20 Mar 2019 16:59:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF356B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:59:22 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id r8so4938018ywh.10
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:59:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dlgp2MdnsREd+nc4jSTOXVYFicF0JfUh7ydGu+tAmLg=;
        b=n+xH/H2wRyDken53AW8jOzR7CVDif4x0kqGk+fG8CJdbWPPEBxhAScKHcXV6fuGu7W
         OfsFnhaDdxaPQHL30MC+CwS6QvkFMMk8XF/a8vwhKKcYVrCb9zcgUGdPrB7wCBCI9Q68
         JfhsBgGdQyg/0Cy34GEqyK2Aj4b54YbnigklVjywpTz9hS6ay1dLQUlMjT5PvEwU3sE0
         h7Bf4XqjIAhhwzcpSymmPDjFCi6VOW430BMwZfUTgAHeOu/ELR791aZyu+EqgcMepVzA
         wLOYrk4VJEnaQP5oNHVKPqBiWfEKqGl7/wakX+4mmmSeBr26vpHDx0Wuz1DLlPi5rFDN
         Q5uQ==
X-Gm-Message-State: APjAAAVl4swpyuWxmn7ZVxXFMrTsvRSXqo0iu7/VjXFLrMAsxKbsize9
	39UOsIBx7ppD7VvB52Tu3GQG0caD5npTk2HQhGhCsFNV+FzhJyy93s4BWxGiTTbxI4VL/Z3VzhC
	Z1jZ3ZH11AobxeH3G/d9IkAs0Aa/+rtH6rxEstTjkcAUWaFAX/AaeFd+qAE7/YdKM8Q==
X-Received: by 2002:a0d:dd8d:: with SMTP id g135mr119960ywe.269.1553115562450;
        Wed, 20 Mar 2019 13:59:22 -0700 (PDT)
X-Received: by 2002:a0d:dd8d:: with SMTP id g135mr119932ywe.269.1553115561902;
        Wed, 20 Mar 2019 13:59:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553115561; cv=none;
        d=google.com; s=arc-20160816;
        b=EcYw5rzlSUMh2AhCufXKBYyEeWiZp+rQpy91fVTbQJnJblFqEf+7PcXVSS4MZpjsQK
         aMhjPb6OatfjDtjkLDi4tD3V8MrVlrb0wGnbGMYLKHYqCQsKrbVuWgDKS7vA8iXkFSZX
         h7J0ApTnJ5oemAq82HlLZzcaG99Scee74xfFzfBHaSUv5b4qDb2bdvulUr7/kCQxlDsq
         0BDaFAS6S7EmYDugqHjfUUSQ/ckIZOhN89cenGKp0b+7ZlzMyL305ZQt9/797/RKyQb2
         zt0LVh14x7e3RaCwKhnFpSxA+u1qSjn2h4u8mI74YKlcpigJMdFTmnhz38JBfoSoVbl/
         UNXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dlgp2MdnsREd+nc4jSTOXVYFicF0JfUh7ydGu+tAmLg=;
        b=qk0+N6eW+B7xIEn9lguPQPgnX4cNN3WKxFKWW6MLFshOPwxgV0/YfIbru88kB1wmWl
         Bu1ox98PlPBOFyWN65bnAPKsfKmgZ8WfBSUFtcH7nTKcELiV3C1TcKdqQ4nPEpgqF3PJ
         EQA9yChuh43MdhNYMedQ9Y8Q4DD/bM0jQvnwXkTeqoglnVz8gCu/zgVTYvbYAfZCKgKg
         flbQzNSzYqUfgbdSzXmobM8JuUOuPQuqZ1qoYhfYtSU8G5tZGKsXVU5QAKO6pSqEoTmK
         ju8iID56RnDWuEX2z3Xh4RWw6wd8QB+qXE0koNnzTkA/4eCSr5vhU523UaXGF+BJFCAI
         8HQw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=YFtoHdtQ;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d206sor1468726ybd.200.2019.03.20.13.59.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:59:17 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=YFtoHdtQ;
       spf=temperror (google.com: error in processing during lookup of hannes@cmpxchg.org: DNS error) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dlgp2MdnsREd+nc4jSTOXVYFicF0JfUh7ydGu+tAmLg=;
        b=YFtoHdtQVZ9UvOqKhzJE/FYr9snrw4U6DTalkvSVji/qTo+Xewly3DaO54P3LXZ00N
         DCkyCPgHLU6+6peHoQGzFBSNMQ1D4WoC/K1tOo2p1k1QMllPOcX8vSVwg9ot+itOWnBs
         MFSu8ao8DVt34JuqAB4FTA2K8AzQbqj4tAMwjc16oPP9nyN3gqyDdycq/R2eLmQM1eCm
         CnCh36QBmpaU1h3lP7b4Ro7nEi9FuAIhuZCMDi2tUulho3iic+3sgGjB6yCKgjn0ex4S
         yCIqdP/J6iBjKtO2cK0DNc80TYtqEbIYBWvnXXYaQEyWh5PpPvvGz5YB8bpekTOlJPAr
         wsjw==
X-Google-Smtp-Source: APXvYqzXoLupL+n72SdHmbmKb5aynrZfObbwlDHWH7olugK1jMsRTp+3aMDyANbp/+KSCDMMXL6v6A==
X-Received: by 2002:a25:e54a:: with SMTP id c71mr6067ybh.336.1553115557703;
        Wed, 20 Mar 2019 13:59:17 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::2:b52c])
        by smtp.gmail.com with ESMTPSA id s18sm974233ywg.100.2019.03.20.13.59.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 13:59:16 -0700 (PDT)
Date: Wed, 20 Mar 2019 16:59:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: gregkh@linuxfoundation.org, tj@kernel.org, lizefan@huawei.com,
	axboe@kernel.dk, dennis@kernel.org, dennisszhou@gmail.com,
	mingo@redhat.com, peterz@infradead.org, akpm@linux-foundation.org,
	corbet@lwn.net, cgroups@vger.kernel.org, linux-mm@kvack.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@android.com
Subject: Re: [PATCH v6 4/7] psi: split update_stats into parts
Message-ID: <20190320205915.GC19382@cmpxchg.org>
References: <20190319235619.260832-1-surenb@google.com>
 <20190319235619.260832-5-surenb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319235619.260832-5-surenb@google.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 04:56:16PM -0700, Suren Baghdasaryan wrote:
> Split update_stats into collect_percpu_times and update_averages for
> collect_percpu_times to be reused later inside psi monitor.
> 
> Signed-off-by: Suren Baghdasaryan <surenb@google.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

