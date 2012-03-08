Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 004746B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 09:36:25 -0500 (EST)
Message-ID: <4F58C3E2.7010009@gmail.com>
Date: Thu, 08 Mar 2012 15:36:18 +0100
From: Florian Schmaus <fschmaus@gmail.com>
MIME-Version: 1.0
Subject: Re: (un)loadable module support for zcache
References: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com> <04499111-84c1-45a2-a8e8-5c86a2447b56@default>
In-Reply-To: <04499111-84c1-45a2-a8e8-5c86a2447b56@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org
Cc: Stefan Hengelein <ilendir@googlemail.com>, sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, Andor Daam <andor.daam@googlemail.com>, i4passt@lists.informatik.uni-erlangen.de, devel@linuxdriverproject.org, Nitin Gupta <ngupta@vflare.org>

On 03/05/12 17:57, Dan Magenheimer wrote:
> I think the answer here is for cleancache (and frontswap) to
> support "lazy pool creation".  If a backend has not yet
> registered when an init_fs/init call is made, cleancache
> (or frontswap) must record the attempt and generate a valid
> "fake poolid" to return.  Any calls to put/get/flush with
> a fake poolid is ignored as the zcache module is not
> yet loaded.  Later, when zcache is insmod'ed, it will attempt
> to register and cleancache must then call the init_fs/init
> routines (to "lazily" create the pools), obtain a "real poolid"
> from zcache for each pool and "map" the fake poolid to the real
> poolid on EVERY get/put/flush and on pool destroy (umount/swapoff).

We were thinking about how to make cleancache and frontswap able to cope 
with the mounting of filesystems and running of swapon when there is no 
backend registered without adding an indirection caused by a fake pool 
id map.

We figured a way to deal with this in cleancache would be to store the 
struct super_block pointers in an array for every call to init_fs and 
the uuids and struct super_blocks pointers in different arrays for every 
call to init_shared_fs. When a filesystem unmounts before a backend is 
registered, its entries in the respective arrays are removed.
While no backend is registered, the put_page() and invalidate_page() are 
ignored and get_page() fails. As soon as a backend registers the init_fs 
and init_shared_fs functions are called for the struct super_block 
pointers (and uuids) stored in the according arrays.

For frontswap we are aiming for a similar approach by remembering the 
types for every call to init and failing put_page() and ignoring 
get_page() and invalidate_page().
Again, when a backend registers init is called for every type stored.

This should allow backends to register with cleancache and frontswap 
even after the mounting of filesystems and/or swapon is run. Therefore 
it should allow zcache to be insmodded. This would be a first step to 
allow rmmodding of zcache aswell.

Is this approach feasible?

Stefan, Florian, and Andor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
