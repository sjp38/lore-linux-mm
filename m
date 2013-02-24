Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 05C706B0005
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 23:04:09 -0500 (EST)
Message-ID: <51299138.1070505@ubuntu.com>
Date: Sat, 23 Feb 2013 23:04:08 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <5127E8B7.9080202@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <20130224035851.GA5916@gmail.com>
In-Reply-To: <20130224035851.GA5916@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-mm@kvack.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/23/2013 10:58 PM, Zheng Liu wrote:
> Hi Phillip,
> 
> I think we need to initiate writeout.  IIRC, when we try to free
> pages, we would wait on page writeback.  That will cause a huge
> latency for

Not really.  Most writes are initiated by the flush kernel thread.
The only way the old implementation would help applications avoid
delays in writing was if it slowly writes just the right amount of
data to use a significant amount of cache pages, but not quite enough
for the kernel flush thread to start writing it out, and then suddenly
tried to burst a lot of writes.

> some applications.  If these pages have been written out, we just
> need to invalidate them.  IMO we can move these pages to inactive
> list and write them out.

If you want to be sure writes start now, you should be using
sync_file_range().  If you combine that with posix_fadvise, then you
can be sure that writing starts now, and that the page cache will
prefer to discard that data ahead of other cached pages.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQEcBAEBAgAGBQJRKZE4AAoJEJrBOlT6nu75rmcIAIBmhok62teELHqDSLUA2Mj7
bEM10Iosghsq+QqH4kWq2U7S/eA935JVN2xKduQAL0/doO0+qTHIha40Fl9b7Q2D
k17cush2Z26tk7qZcQ9zh1HKfKQ1mxReU7eSkdv7FWdkOo7DTA71yk/2Ej7Zuv+E
4Fl26HYhNQADK6t5Y1hyfpG+MebuTM/jFrfCD5RRO1cnDxrU8xK3NTEEmrooZsB1
buUfWE0Wfm9MaSvArft6YVMr0XJlCUEUwkV/0LDBGBQs+YjdawQ9wPYdNTLhiijP
Y7HEZJe5Oi9mzeQNcr9QwGIqA4dSVW6XqiGDHLMDNanXhgnEhH1S3CmsZXL37OM=
=JoEo
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
