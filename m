Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 912AF440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 08:04:15 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id k190so3915934pga.10
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 05:04:15 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p3si6244390pld.546.2017.11.09.05.04.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Nov 2017 05:04:13 -0800 (PST)
Date: Thu, 9 Nov 2017 05:04:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Replace-simple_strtoul-with-kstrtoul
Message-ID: <20171109130412.GA1094@bombadil.infradead.org>
References: <CGME20171109113212epcas5p4b93d4830869468901f4003bde11e3d16@epcas5p4.samsung.com>
 <1510226898-4310-1-git-send-email-manjeet.p@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1510226898-4310-1-git-send-email-manjeet.p@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manjeet Pawar <manjeet.p@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, mhocko@suse.com, akpm@linux-foundation.org, hughd@google.com, a.sahrawat@samsung.com, pankaj.m@samsung.com, lalit.mohan@samsung.com, Vinay Kumar Rijhwani <v.rijhwani@samsung.com>, Rohit Thapliyal <r.thapliyal@samsung.com>

On Thu, Nov 09, 2017 at 04:58:18PM +0530, Manjeet Pawar wrote:
> simple_strtoul() is obselete now, so using newer function kstrtoul()
> 
> Signed-off-by: Manjeet Pawar <manjeet.p@samsung.com>
> Signed-off-by: Vinay Kumar Rijhwani <v.rijhwani@samsung.com>
> Signed-off-by: Rohit Thapliyal <r.thapliyal@samsung.com>

NAK NAK NAK.

You haven't tested this on a 64-bit big-endian machine.

>  static int __init set_hashdist(char *str)
>  {
> -	if (!str)
> +	if (!str || kstrtoul(str, 0, (unsigned long *)&hashdist))
>  		return 0;
> -	hashdist = simple_strtoul(str, &str, 0);
>  	return 1;

The context missing from this patch is:

int hashdist = HASHDIST_DEFAULT;

So you're taking the address of an int and passing it to a function
which is expecting a pointer to an unsigned long.  That works on a
32-bit machine because ints and longs are the same size.  On a 64-bit
little-endian machine, the bits are in the right place, but kstrtoul()
will overwrite the 32 bits after the int with zeroes.  On a 64-bit
big-endian machine, you'll overwrite the int that you're pointing to
with zeroes and the 32 bits after the int will have the data you're
looking for.

There's a kstrtoint().  Why would you not just use that?

Also, I'm shocked that this went through a chain of three different
sign-offs with nobody noticing the problem.  Do none of you understand C?

(similar problems snipped).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
