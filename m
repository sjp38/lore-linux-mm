Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C0BFF6B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 01:08:25 -0400 (EDT)
Received: by iyn15 with SMTP id 15so7225362iyn.34
        for <linux-mm@kvack.org>; Sun, 14 Aug 2011 22:08:23 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 15 Aug 2011 00:08:23 -0500
Message-ID: <CAML7nqd9_F4L0M7ynLFz4HKET94n2mwsk42Z7g2EjAfYnD-JgQ@mail.gmail.com>
Subject: issue with direct reclaims and kswapd reclaims on 2.6.35.7
From: Jeffrey Vanhoof <jdv1029@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On a=A02.6.35.7 based kernel, on a portable device with 512MB RAM, I am
seeing the following issues while consuming 20Mbps video content:
1) direct reclaims occurring quite frequently, resulting in delayed
file read requests
2) direct reclaims falling into congestion_wait() even though no
congestion at the time, this results in video jitter.
3) kswapd not reclaiming pages quickly enough due to falling into
congestion_wait() very often.
4) power consumption is degraded as a result of time being spent in
io_schedule_timeout() called within congestion_wait(). (the power
c-state will stay in C0)

Are there specific patches which can be easily back-ported to K35
which may address most of these issues?

For file read performance, I believe it is better for kswapd to
reclaim memory instead of hitting a direct reclaim, and for power it
would be best that while reclaiming memory in kswapd that
io_schedule()/io_schedule_timeout() is never called unless absolutely
required.

Are any of the workarounds listed below appropriate to use?
1) change the congestion_wait() timeout value in balance_pgdat() from
HZ/10 to HZ/50. This allows for faster reclaims in kswapd and limits
the time spend in congestion_wait().
2) change SWAP_CLUSTER_MAX from 32 to 128 or higher (swap is enabled,
but there is no swap).
3) change DEF_PRIORITY from 12 to 9. This results in a larger scan and
pages are reclaimed quicker. Also, this causes congestion_wait() to be
called less frequently due to the likelyhood of pages being found with
increase priority.

Any help would be appreciated.

Thanks,
Jeff V.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
