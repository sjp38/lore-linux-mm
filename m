Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 24D846B006C
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 17:42:58 -0400 (EDT)
Message-ID: <50919B5D.9000100@cesarb.net>
Date: Wed, 31 Oct 2012 19:42:53 -0200
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] mm: frontswap: lazy initialization to allow tmem
 backends to build/run as modules
References: <1351696074-29362-1-git-send-email-dan.magenheimer@oracle.com> <1351696074-29362-3-git-send-email-dan.magenheimer@oracle.com> <50915A5C.8000303@linux.vnet.ibm.com>
In-Reply-To: <50915A5C.8000303@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, konrad.wilk@oracle.com, minchan@kernel.org, fschmaus@gmail.com, andor.daam@googlemail.com, ilendir@googlemail.com, akpm@linux-foundation.org, mgorman@suse.de

Em 31-10-2012 15:05, Seth Jennings escreveu:
> On 10/31/2012 10:07 AM, Dan Magenheimer wrote:
>> +#define MAX_INITIALIZABLE_SD 32
>
> MAX_INITIALIZABLE_SD should just be MAX_SWAPFILES
>
>> +static int sds[MAX_INITIALIZABLE_SD];
>
> Rather than store and array of enabled types indexed by type, why not
> an array of booleans indexed by type.  Or a bitfield if you really
> want to save space.

Since it is indexed by swap_info_struct's type, and frontswap already 
pokes directly inside the swap_info_structs, it would be even cleaner to 
use a boolean field within the swap_info_struct.

And if you are using a field within the swap_info_struct, you could 
overload the already existing frontswap_map field, which should only 
have any use if you have a frontswap module already loaded. That is, 
move the vzalloc of the frontswap_map to within frontswap's init 
function, and call it outside the swapfile_lock/swapon_mutex. This also 
has the advantage of not allocating the frontswap_map when it is not 
going to be used.

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
