Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF6AC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:40:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ACEC206E0
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:40:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ACEC206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E61756B0010; Wed, 12 Jun 2019 14:40:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E123F6B0266; Wed, 12 Jun 2019 14:40:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD9F66B0269; Wed, 12 Jun 2019 14:40:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAF9F6B0010
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:40:40 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id i6so5693621vsp.15
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:40:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MAEdGWtMT+73VzWnKUa2R//cIsfAOphq8gc0YAftk3c=;
        b=Skg01DIMMVWnhNX5ua6fTcxdioa8swM+8XSpVpygCOIpS+z3OJJ4ZF1lqvKDx/3mXA
         QaYhFIyhMX6v9oernaXxV+WkARih/DGwTBdsgmKGlnuztnMplxLgp+7BmEc4XBq44npF
         vQOn1Pz34yea3IASXrqtQLYTCrFRKlZGP1VRLRhEAnivSA0E2VneopbvtPdmn3zuk/CO
         4RO1gops5s+Jyv++YGepa8CMi+WGxwHPLMILmfQG1ihf8+birTOpaKiy7R7hlsPtSnLw
         U6QasKA8tye5aZDfc8TkK9xXjdjFC5q5gZAiz/K0x9uqb7Dj39Er9rCQ1Jegbesl5cH8
         OQFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUpCY5VNFCu0+K8WyXvNDQywd7lA9LDBS3Johm+t2nkNOTHmflu
	yc7+6BEM8UmRxU9gZ/oH+bXNpvxXn75zehAE1Gi+RLiL1GzH8QHzPMHkQmzwtXi1Q9oMSO1kAbZ
	Vjy7e4T3uIL/Xa6Uu0a7m3QMt8KSN5oJeJx67Yrcdsh+E4iRgdbCvPCk5djCFAbfG6Q==
X-Received: by 2002:a1f:7f0e:: with SMTP id o14mr4902346vki.67.1560364840381;
        Wed, 12 Jun 2019 11:40:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvEQDn0hmfpjmQ4P6ELugxcG9kTA06UfOqAgBOLx84GqrsJLd2Uf2Fo2ifp5xSgnfCitPe
X-Received: by 2002:a1f:7f0e:: with SMTP id o14mr4902281vki.67.1560364839745;
        Wed, 12 Jun 2019 11:40:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560364839; cv=none;
        d=google.com; s=arc-20160816;
        b=BKjiI3N9k2pAKBhBgEqm/hkxtLFo0lcNxnZNOfpP/4Ee0z9noU6Mlcj5UvDkg59D+o
         QjfCN8EmA7dtb8DXS4CVtwMXVv3lz5iy7ufJLai+tMH+yGl1CiSWpM9g5F0VpAfQ3owm
         wASoQZKAWopyswSxove29VbtaKBIJa9cD0ZpqINmja/6IrOVt9hZdpPRbsTM2g+yvTfN
         QjCi+KM81vMEku9a8zoLa7TUMd6DdRbjPeaeLL4R/BGvdWKot1SoarU1HOxxd6+HY9ke
         S+2wGxhGlcdnYMe6S5GJtDEsQbQlzRDX6lq7j20h7N7JjvQ7kqxX5YpnI0kPVaT+bNfV
         Zdpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MAEdGWtMT+73VzWnKUa2R//cIsfAOphq8gc0YAftk3c=;
        b=go9mmZxissyaLjlgoRELouB8bPcpmvYcumFc1sKfyI82a0sZB2b6xDruDR1DCj1p4X
         TvbisQ0H8MbWxHL7XEuWc50JJ5zenE8FVtg2jni4Oui+6LrB/SvcVfT6jZ82mUH8DYR1
         2OJfg6yA2C92h4nJVez4JqRCIw7X9dV5ZMV7+hRee41RgoJv2PHMPV9wmDynLze6++zr
         xo+zxGMn+1z7ZiIOqLHyXMLfgHTpBS+Xs3xGSvtNIH9be1B9LZsTHu/dOXKR2fO6AQXt
         HboGSHwJyLLVvkgCJWyOOdb6sO1IX01YQxMiJpmeOWUyOC5UzEv7m0DSQRvLbdO3yDw3
         krqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v6si198787vsm.112.2019.06.12.11.40.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 11:40:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aquini@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aquini@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E62313082A9B;
	Wed, 12 Jun 2019 18:40:28 +0000 (UTC)
Received: from x230.aquini.net (dhcp-17-61.bos.redhat.com [10.18.17.61])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 4CA6B6015E;
	Wed, 12 Jun 2019 18:40:28 +0000 (UTC)
Date: Wed, 12 Jun 2019 14:40:26 -0400
From: Rafael Aquini <aquini@redhat.com>
To: Joel Savitz <jsavitz@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>, linux-mm@kvack.org
Subject: Re: [RESEND PATCH v2] mm/oom_killer: Add task UID to info message on
 an oom kill
Message-ID: <20190612184026.GD5313@x230.aquini.net>
References: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560362273-534-1-git-send-email-jsavitz@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 12 Jun 2019 18:40:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 01:57:53PM -0400, Joel Savitz wrote:
> In the event of an oom kill, useful information about the killed
> process is printed to dmesg. Users, especially system administrators,
> will find it useful to immediately see the UID of the process.
> 
> In the following example, abuse_the_ram is the name of a program
> that attempts to iteratively allocate all available memory until it is
> stopped by force.
> 
> Current message:
> 
> Out of memory: Killed process 35389 (abuse_the_ram)
> total-vm:133718232kB, anon-rss:129624980kB, file-rss:0kB,
> shmem-rss:0kB
> 
> Patched message:
> 
> Out of memory: Killed process 2739 (abuse_the_ram),
> total-vm:133880028kB, anon-rss:129754836kB, file-rss:0kB,
> shmem-rss:0kB, UID 0
> 
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Joel Savitz <jsavitz@redhat.com>
> ---
>  mm/oom_kill.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3a2484884cfd..af2e3faa72a0 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -874,12 +874,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
>  	 */
>  	do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
>  	mark_oom_victim(victim);
> -	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> +	pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB, UID %d\n",
>  		message, task_pid_nr(victim), victim->comm,
>  		K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>  		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> -		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> +		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> +		from_kuid(&init_user_ns, task_uid(victim)));
>  	task_unlock(victim);
>  
>  	/*
> -- 
> 2.18.1
> 
Acked-by: Rafael Aquini <aquini@redhat.com>

