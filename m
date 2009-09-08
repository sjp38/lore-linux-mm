Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 81F3F6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 12:11:33 -0400 (EDT)
Subject: Re: [PATCH v3 2/5] kmemleak: add clear command support
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <1252111494-7593-3-git-send-email-lrodriguez@atheros.com>
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com>
	 <1252111494-7593-3-git-send-email-lrodriguez@atheros.com>
Content-Type: text/plain
Date: Tue, 08 Sep 2009 17:11:28 +0100
Message-Id: <1252426288.12145.112.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Luis R. Rodriguez" <lrodriguez@Atheros.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi, mcgrof@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-09-04 at 17:44 -0700, Luis R. Rodriguez wrote:
>  /*
> + * We use grey instead of black to ensure we can do future
> + * scans on the same objects. If we did not do future scans
> + * these black objects could potentially contain references to
> + * newly allocated objects in the future and we'd end up with
> + * false positives.
> + */
> +static void kmemleak_clear(void)
> +{
> +	struct kmemleak_object *object;
> +	unsigned long flags;
> +
> +	stop_scan_thread();
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(object, &object_list, object_list) {
> +		spin_lock_irqsave(&object->lock, flags);
> +		if ((object->flags & OBJECT_REPORTED) &&
> +		    unreferenced_object(object))
> +			object->min_count = -1;
> +		spin_unlock_irqrestore(&object->lock, flags);
> +	}
> +	rcu_read_unlock();
> +
> +	start_scan_thread();
> +}

Do we need to stop and start the scanning thread here? When starting it,
it will trigger a memory scan automatically. I don't think we want this
as a side-effect, so I dropped these lines from your patch.

Also you set min_count to -1 here which means black object, so a
subsequent patch corrects it. I'll set min_count to 0 here in case
anyone bisects over it.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
