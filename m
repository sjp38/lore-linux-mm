Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id A8E996B0062
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 14:05:13 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so5760796vbb.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 11:05:12 -0800 (PST)
Date: Mon, 19 Dec 2011 11:05:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Android low memory killer vs. memory pressure notifications
In-Reply-To: <20111219074843.GA21324@barrios-laptop.redhat.com>
Message-ID: <alpine.DEB.2.00.1112191059010.19949@chino.kir.corp.google.com>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219074843.GA21324@barrios-laptop.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 19 Dec 2011, Minchan Kim wrote:

> Kernel should have just signal role when resource is not enough.
> It is desirable that killing is role of user space.

The low memory killer becomes an out of memory killer very quickly if 
(1) userspace can't respond fast enough and (2) the killed thread cannot 
exit and free its memory fast enough.  It also requires userspace to know 
which threads are sharing memory such that they may all be killed; 
otherwise, killing one thread won't lead to future memory freeing.

If the system becomes oom before userspace can kill a thread, then there's 
no guarantee that it will ever be able to exit.  That's fixed in the 
kernel oom killer by allowing special access to memory reserves 
specifically for this purpose, which userspace can't provide.

So the prerequisites for this to work correctly every time would be to 
ensure that points (1) and (2) above can always happen.  I'm not seeing 
where that's proven, so presumably you'd still always need the kernel oom 
killer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
