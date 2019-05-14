Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2E4BC04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:22:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 733FE2147A
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 13:22:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 733FE2147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A24D6B0003; Tue, 14 May 2019 09:22:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 052C66B0006; Tue, 14 May 2019 09:22:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E84C16B0007; Tue, 14 May 2019 09:22:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFF16B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 09:22:52 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v5so9894098wrn.6
        for <linux-mm@kvack.org>; Tue, 14 May 2019 06:22:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=30MZy6w8/UHFwckByseMshUTKJ0XAaQAYBwkRUyEATg=;
        b=VIKgv0iuPVL8ouEKxl21U/+K9AWrgxZ6RX8LFS0sQimOVU1zBhw/O6CnM1tDODgvig
         zL1d1+KmtUvqyjnb+wdYwpXVrF2r8LybrkIEPzYWkjOOI/mm3b4B6INWy1nskaoeDG87
         T1crkx1WChYvKXlRj716mDHV/f3JfO0RVV+k8XxspOXWu7w0alml7N+2vlF/MBdXrKHR
         s+36VO+lXJbA2TtkZlCVN1ZdNq+58Nu/o8UR9wILrDYFwSkJjucvK/eChKb6U8ESv046
         jNZRRj6BmqwfZquh4sYF0J1a254UDjCeg3XEHQeuJGb+gWn4pn1hRDIhN6OjlaMOxgeS
         lrVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUITZFe1bH7AJMdRYVhUL/nVa0B+PN0R/BRECvU/a+4mjMlnUAR
	m1ih+tATKqhHxO7l2vwRkojnFhvVz8RHaIMgJhMMfnDTkiJwlDEnBlbZxrO7Z8SEjcHvV2tz0ro
	1l4wXDmie5sDrndOe3IiJetlw8cvlEAgG/BtFHwBfu1j/A8fdTwisG7XLEt2wOnqS+g==
X-Received: by 2002:adf:dbce:: with SMTP id e14mr21291592wrj.249.1557840172178;
        Tue, 14 May 2019 06:22:52 -0700 (PDT)
X-Received: by 2002:adf:dbce:: with SMTP id e14mr21291543wrj.249.1557840171164;
        Tue, 14 May 2019 06:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557840171; cv=none;
        d=google.com; s=arc-20160816;
        b=Xj2Wd/WEwA08kzrinhMtbdTXe8Tl1sZ0MFRMl6+0Pvbs8VR0wbmqMMRx77mBTld8XE
         J9oH0+f0QsLahreKKfjI0dX7EJUWvRxoxdwF70ODz9LHPkcMj6cSE7ZVXSPA+1wilsy0
         5sxlYK1oOMc9+AvB864IFxii0tj2nYRunyDeGWVcQZVbkwCVK6sysP1iWLsAX3tT8LmJ
         sWPsct5ipt+thZBtyyBIzdXOSiXaRviyB4AdV4ttMh0savKl8ryquRcT+sJ1XO0txMc4
         d8GdJUB20nM0AT6uVL9uqiXuwCW7dfXa+uv2lOdIlZKa+DCufkN5wyPxUjdLreOmLeC9
         qniA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=30MZy6w8/UHFwckByseMshUTKJ0XAaQAYBwkRUyEATg=;
        b=bHJyexSHzbCsYB25ETivG9A4lFh3yIwOYMRiLbufcjxph8LdHlAqYX/qyK2txcZsvj
         J/EeJQGzA5aG2Jq8wY7nMXgTHbu7RFlWU2sjLRfSjYh5zng0gw6sDoTmbI0QGsLMEOsG
         vrj7XgtUj7iJ9ayBYWAHS8Lwjvy2CFGpgV6wFT7W8qIuuji4ctI/vboQl0VOqQfQCW+t
         R/0qS7RiKP3x8gIye9OonZl4o3XtMFvPus1SXYeVkKpw3flFXlJm91czVLIUkTDcm5Ml
         h0XDi89axLt8MYejblNMeZ8fV6ZAWDzJr2CGe/aG6n748rJ2uYb+BwO4e0QLcq9Vdqdw
         CY3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor1633219wmg.10.2019.05.14.06.22.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 06:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of atomlin@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=atomlin@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwC3BFcZP2L4DGiVRCHRXmxW9RKCIZlsYi2qXCsH8aM1VNcEqntfDgjJ/dMsnZG1ORhmCvuTA==
X-Received: by 2002:a1c:a7cc:: with SMTP id q195mr11561566wme.53.1557840170835;
        Tue, 14 May 2019 06:22:50 -0700 (PDT)
Received: from localhost (cpc111743-lutn13-2-0-cust844.9-3.cable.virginm.net. [82.17.115.77])
        by smtp.gmail.com with ESMTPSA id k30sm4597150wrd.0.2019.05.14.06.22.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 06:22:50 -0700 (PDT)
Date: Tue, 14 May 2019 14:22:49 +0100
From: Aaron Tomlin <atomlin@redhat.com>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH RFC v2 3/4] mm/ksm: introduce force_madvise knob
Message-ID: <20190514132249.h233crdsz3b7akys@atomlin.usersys.com>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514131654.25463-4-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190514131654.25463-4-oleksandr@redhat.com>
X-PGP-Key: http://pgp.mit.edu/pks/lookup?search=atomlin%40redhat.com
X-PGP-Fingerprint: 7906 84EB FA8A 9638 8D1E  6E9B E2DE 9658 19CC 77D6
User-Agent: NeoMutt/20180716-1637-ee8449
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 2019-05-14 15:16 +0200, Oleksandr Natalenko wrote:
> Present a new sysfs knob to mark task's anonymous memory as mergeable.
> 
> To force merging task's VMAs, its PID is echoed in a write-only file:
> 
>    # echo PID > /sys/kernel/mm/ksm/force_madvise
> 
> Force unmerging is done similarly, but with "minus" sign:
> 
>    # echo -PID > /sys/kernel/mm/ksm/force_madvise
> 
> "0" or "-0" can be used to control the current task.
> 
> To achieve this, previously introduced ksm_enter()/ksm_leave() helpers
> are used in the "store" handler.
> 
> Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
> ---
>  mm/ksm.c | 68 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 68 insertions(+)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index e9f3901168bb..22c59fb03d3a 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -2879,10 +2879,77 @@ static void wait_while_offlining(void)
>  
>  #define KSM_ATTR_RO(_name) \
>  	static struct kobj_attribute _name##_attr = __ATTR_RO(_name)
> +#define KSM_ATTR_WO(_name) \
> +	static struct kobj_attribute _name##_attr = __ATTR_WO(_name)
>  #define KSM_ATTR(_name) \
>  	static struct kobj_attribute _name##_attr = \
>  		__ATTR(_name, 0644, _name##_show, _name##_store)
>  
> +static ssize_t force_madvise_store(struct kobject *kobj,
> +				     struct kobj_attribute *attr,
> +				     const char *buf, size_t count)
> +{
> +	int err;
> +	pid_t pid;
> +	bool merge = true;
> +	struct task_struct *tsk;
> +	struct mm_struct *mm;
> +	struct vm_area_struct *vma;
> +
> +	err = kstrtoint(buf, 10, &pid);
> +	if (err)
> +		return -EINVAL;
> +
> +	if (pid < 0) {
> +		pid = abs(pid);
> +		merge = false;
> +	}
> +
> +	if (!pid && *buf == '-')
> +		merge = false;
> +
> +	rcu_read_lock();
> +	if (pid) {
> +		tsk = find_task_by_vpid(pid);
> +		if (!tsk) {
> +			err = -ESRCH;
> +			rcu_read_unlock();
> +			goto out;
> +		}
> +	} else {
> +		tsk = current;
> +	}
> +
> +	tsk = tsk->group_leader;
> +
> +	get_task_struct(tsk);
> +	rcu_read_unlock();
> +
> +	mm = get_task_mm(tsk);
> +	if (!mm) {
> +		err = -EINVAL;
> +		goto out_put_task_struct;
> +	}
> +	down_write(&mm->mmap_sem);
> +	vma = mm->mmap;
> +	while (vma) {
> +		if (merge)
> +			ksm_enter(vma->vm_mm, vma, &vma->vm_flags);
> +		else
> +			ksm_leave(vma, vma->vm_start, vma->vm_end, &vma->vm_flags);
> +		vma = vma->vm_next;
> +	}
> +	up_write(&mm->mmap_sem);
> +	mmput(mm);
> +
> +out_put_task_struct:
> +	put_task_struct(tsk);
> +
> +out:
> +	return err ? err : count;
> +}
> +KSM_ATTR_WO(force_madvise);
> +
>  static ssize_t sleep_millisecs_show(struct kobject *kobj,
>  				    struct kobj_attribute *attr, char *buf)
>  {
> @@ -3185,6 +3252,7 @@ static ssize_t full_scans_show(struct kobject *kobj,
>  KSM_ATTR_RO(full_scans);
>  
>  static struct attribute *ksm_attrs[] = {
> +	&force_madvise_attr.attr,
>  	&sleep_millisecs_attr.attr,
>  	&pages_to_scan_attr.attr,
>  	&run_attr.attr,

Looks fine to me.

Reviewed-by: Aaron Tomlin <atomlin@redhat.com>

-- 
Aaron Tomlin

