Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06946C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D264214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:58:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D264214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CA138E0003; Tue, 12 Mar 2019 10:58:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 028E18E0002; Tue, 12 Mar 2019 10:58:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E33D98E0003; Tue, 12 Mar 2019 10:58:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 861208E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:58:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x13so1212109edq.11
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:58:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wl7Ff/wPObHM79OrDDPjxHJ6QXsnrK3/b8nVrJfMOtc=;
        b=Mswcy233terDpA9lq20M40r3Q8vbR5PPHWjZhnJTXKRsYNIgMAZQyDIsLwS4z9450j
         LzKXFzxRXDbQ/1tmxVGsDLeqXtps6p/UySDirPr/g0MIqWRCsdICtLCOQGF2DK6qVuSN
         w+hygaBJUZecY5228SXaBw8o88n2uYqYpfdsZt2zDFnZ55MWc0bX5Aja22zuMy+lnaDI
         q64mO3DAAgfk+ZzYZvs4DGux5CwMS/BQt2EUaQzWOVg4dOnK+5W6eVpgo+vbPRpfHFBs
         Bjxa3gpEzryORsXd66kkN4O+2XBm3fVbDmF48Z8dVDXfruR1NFkhligbHLg+wDdYoORS
         UmyA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXvm3CIxjvU1WS8xKCi/1ZEa45mxneUre2h6DmdrvbCCjNv90+y
	TM1xJC7kj7y87xUOtFUx7z4LpHgCY084HciF7oZHd2EiOYppBAbZ4jmxnNXo7bfcKcrIWFjdt5/
	0Pj2FigeqeyrDOU+VJS8XmKlxvd8O7lxe/LfhsvehnjZHXoo1/+a68nfaLGRjiQc=
X-Received: by 2002:a05:6402:750:: with SMTP id p16mr2838679edy.268.1552402697140;
        Tue, 12 Mar 2019 07:58:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYTRxYGFVjCRch2/Y2s03FqvauzRmj1EWNp9FFDJcwJqjwCyHV0PucIryQbFHe79OSBRQD
X-Received: by 2002:a05:6402:750:: with SMTP id p16mr2838628edy.268.1552402696260;
        Tue, 12 Mar 2019 07:58:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552402696; cv=none;
        d=google.com; s=arc-20160816;
        b=TZLQF1q3yBqeNI4g6X9nojv435SLKGlQQjlHjAnlsHzEQwDZ2XNy1J8fJhWCINdD/i
         uKBbTSAYEH9ofQxkRob1Nr9VfX8nVc2mRfxAH+jqBxckg4bvT1aY9+tbfvnNItEP7fMP
         H2abUy0fXV840+LD668gaOoe9sFWw7wbjXUYiLsT0DnDNZN9TH5Hcp35sulT7p+FnY3A
         8PA+ns884Tay/9fA2bLqED9A5Vq17oG91gUPpEkOt0/v6gVcCUqCztJYBDbZLQscOkgO
         GZwhZ5BMIN8yT6wiXV1unOjAqiiirToiT2K5BIPZFw7ocs0DlBVdPoX8ALh4vt6kAPRb
         cX6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wl7Ff/wPObHM79OrDDPjxHJ6QXsnrK3/b8nVrJfMOtc=;
        b=RvnYkgtLTq4nA2CJQPG5G4y6mKKosClCbBDctKfU1jJ73lRW9s3IHqllsI5W1x8ipz
         NwyRLzaa62pWJw+dhg3HUnVKAdQEyUATd1oVgH5JTEBAyK4ekFb8YTPtOjDMUNJqrI8d
         FalnXmbixeaEIUY+qj2hdp8enp7XCKu2fTOZVlKTK8kn7e9FT0rT7FDYUNBpkXIVoPZk
         BGWcpBWOHuv6z8lG62XZX61HvVjS3XQLRxmpL8iXiwBLxBO2WtqGYjkM+mLQb8TxdYbM
         E+F22xvw/f4h2+mCdzqKbZ/PfMfPqiVtTqTZe01p4ZJpdLu9OJu0XciahQPgiN/jQB3R
         cRlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z4si468394ejq.224.2019.03.12.07.58.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 07:58:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 44819B682;
	Tue, 12 Mar 2019 14:58:15 +0000 (UTC)
Date: Tue, 12 Mar 2019 15:58:13 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/slab: protect cache_reap() against CPU and memory hot
 plug operations
Message-ID: <20190312145813.GS5721@dhcp22.suse.cz>
References: <20190311191701.24325-1-ldufour@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311191701.24325-1-ldufour@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-03-19 20:17:01, Laurent Dufour wrote:
> The commit 95402b382901 ("cpu-hotplug: replace per-subsystem mutexes with
> get_online_cpus()") remove the CPU_LOCK_ACQUIRE operation which was use to
> grap the cache_chain_mutex lock which was protecting cache_reap() against
> CPU hot plug operations.
> 
> Later the commit 18004c5d4084 ("mm, sl[aou]b: Use a common mutex
> definition") changed cache_chain_mutex to slab_mutex but this didn't help
> fixing the missing the cache_reap() protection against CPU hot plug
> operations.
> 
> Here we are stopping the per cpu worker while holding the slab_mutex to
> ensure that cache_reap() is not running in our back and will not be
> triggered anymore for this cpu.
> 
> This patch fixes that race leading to SLAB's data corruption when CPU
> hotplug are triggered. We hit it while doing partition migration on PowerVM
> leading to CPU reconfiguration through the CPU hotplug mechanism.

What is the actual race? slab_offline_cpu calls cancel_delayed_work_sync
so it removes a pending item and waits for the item to finish if they run
concurently. So why do we need an additional lock?

> This fix is covering kernel containing to the commit 6731d4f12315 ("slab:
> Convert to hotplug state machine"), ie 4.9.1, earlier kernel needs a
> slightly different patch.
> 
> Cc: stable@vger.kernel.org
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
> ---
>  mm/slab.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 28652e4218e0..ba499d90f27f 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -1103,6 +1103,7 @@ static int slab_online_cpu(unsigned int cpu)
>  
>  static int slab_offline_cpu(unsigned int cpu)
>  {
> +	mutex_lock(&slab_mutex);
>  	/*
>  	 * Shutdown cache reaper. Note that the slab_mutex is held so
>  	 * that if cache_reap() is invoked it cannot do anything
> @@ -1112,6 +1113,7 @@ static int slab_offline_cpu(unsigned int cpu)
>  	cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
>  	/* Now the cache_reaper is guaranteed to be not running. */
>  	per_cpu(slab_reap_work, cpu).work.func = NULL;
> +	mutex_unlock(&slab_mutex);
>  	return 0;
>  }
>  
> -- 
> 2.21.0

-- 
Michal Hocko
SUSE Labs

