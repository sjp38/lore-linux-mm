Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 212086B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 16:25:14 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so4537187eei.7
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 13:25:13 -0800 (PST)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id q43si44945379eeo.33.2014.02.04.13.25.12
        for <linux-mm@kvack.org>;
        Tue, 04 Feb 2014 13:25:13 -0800 (PST)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v7 3/3] PM / Hibernate: use name_to_dev_t to parse resume
Date: Tue, 04 Feb 2014 22:39:43 +0100
Message-ID: <1498007.FMXxByppC2@vostro.rjw.lan>
In-Reply-To: <1391546631-7715-4-git-send-email-sebastian.capella@linaro.org>
References: <1391546631-7715-1-git-send-email-sebastian.capella@linaro.org> <1391546631-7715-4-git-send-email-sebastian.capella@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Capella <sebastian.capella@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>

On Tuesday, February 04, 2014 12:43:51 PM Sebastian Capella wrote:
> Use the name_to_dev_t call to parse the device name echo'd to
> to /sys/power/resume.  This imitates the method used in hibernate.c
> in software_resume, and allows the resume partition to be specified
> using other equivalent device formats as well.  By allowing
> /sys/debug/resume to accept the same syntax as the resume=device
> parameter, we can parse the resume=device in the init script and
> use the resume device directly from the kernel command line.
> 
> Signed-off-by: Sebastian Capella <sebastian.capella@linaro.org>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: Len Brown <len.brown@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> ---
>  kernel/power/hibernate.c |   33 +++++++++++++++++----------------
>  1 file changed, 17 insertions(+), 16 deletions(-)
> 
> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> index cd1e30c..3abd192 100644
> --- a/kernel/power/hibernate.c
> +++ b/kernel/power/hibernate.c
> @@ -970,26 +970,27 @@ static ssize_t resume_show(struct kobject *kobj, struct kobj_attribute *attr,
>  static ssize_t resume_store(struct kobject *kobj, struct kobj_attribute *attr,
>  			    const char *buf, size_t n)
>  {
> -	unsigned int maj, min;
>  	dev_t res;
> -	int ret = -EINVAL;
> +	char *name = kstrdup_trimnl(buf, GFP_KERNEL);
>  
> -	if (sscanf(buf, "%u:%u", &maj, &min) != 2)
> -		goto out;
> +	if (name == NULL)

What about "if (!name)"?

> +		return -ENOMEM;
>  
> -	res = MKDEV(maj,min);
> -	if (maj != MAJOR(res) || min != MINOR(res))
> -		goto out;
> +	res = name_to_dev_t(name);
>  
> -	lock_system_sleep();
> -	swsusp_resume_device = res;
> -	unlock_system_sleep();
> -	pr_info("PM: Starting manual resume from disk\n");
> -	noresume = 0;
> -	software_resume();
> -	ret = n;
> - out:
> -	return ret;
> +	if (res != 0) {

What about "if (res)"?

> +		lock_system_sleep();
> +		swsusp_resume_device = res;
> +		unlock_system_sleep();
> +		pr_info("PM: Starting manual resume from disk\n");
> +		noresume = 0;
> +		software_resume();
> +	} else {
> +		n = -EINVAL;
> +	}
> +
> +	kfree(name);
> +	return n;
>  }
>  
>  power_attr(resume);
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
