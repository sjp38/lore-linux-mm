Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 923716B0006
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 16:33:55 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id c12so1943104ieb.6
        for <linux-mm@kvack.org>; Sat, 23 Feb 2013 13:33:54 -0800 (PST)
Date: Sat, 23 Feb 2013 13:26:36 -0600
From: Rob Landley <rob@landley.net>
Subject: Re: [Bug fix PATCH 2/2] acpi, movablemem_map: Make whatever nodes
 the kernel resides in un-hotpluggable.
References: <1361358056-1793-1-git-send-email-tangchen@cn.fujitsu.com>
	<1361358056-1793-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1361358056-1793-3-git-send-email-tangchen@cn.fujitsu.com>
	(from tangchen@cn.fujitsu.com on Wed Feb 20 05:00:56 2013)
Message-Id: <1361647596.11282.7@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, jiang.liu@huawei.com, wujianguo@huawei.com, hpa@zytor.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, mgorman@suse.de, rientjes@google.com, guz.fnst@cn.fujitsu.com, rusty@rustcorp.com.au, lliubbo@gmail.com, jaegeuk.hanse@gmail.com, tony.luck@intel.com, glommer@parallels.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 02/20/2013 05:00:56 AM, Tang Chen wrote:
> There could be several memory ranges in the node in which the kernel =20
> resides.
> When using movablemem_map=3Dacpi, we may skip one range that have =20
> memory reserved
> by memblock. But if it is too small, then the kernel will fail to =20
> boot. So, make
> the whole node which the kernel resides in un-hotpluggable. Then the =20
> kernel has
> enough memory to use.
>=20
> Reported-by: H Peter Anvin <hpa@zytor.com>
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>

Docs part Acked-by: Rob Landley <rob@landley.net> (with minor =20
non-blocking snark).

> @@ -1673,6 +1675,10 @@ bytes respectively. Such letter suffixes can =20
> also be entirely omitted.
>  			satisfied. So the administrator should be =20
> careful that
>  			the amount of movablemem_map areas are not too =20
> large.
>  			Otherwise kernel won't have enough memory to =20
> start.
> +			NOTE: We don't stop users specifying the node =20
> the
> +			      kernel resides in as hotpluggable so that =20
> this
> +			      option can be used as a workaround of =20
> firmware
> +                              bugs.

I usually see workaround "for", not "of". And your whitespace is =20
inconsistent on that last line.

And I'm now kind of curious what such a workaround would accomplish, =20
but I'm suspect it's obvious to people who wind up needing it.

>  	MTD_Partition=3D	[MTD]
>  			Format: <name>,<region-number>,<size>,<offset>
> diff --git a/arch/x86/mm/srat.c b/arch/x86/mm/srat.c
> index b8028b2..79836d0 100644
> --- a/arch/x86/mm/srat.c
> +++ b/arch/x86/mm/srat.c
> @@ -166,6 +166,9 @@ handle_movablemem(int node, u64 start, u64 end, =20
> u32 hotpluggable)
>  	 * for other purposes, such as for kernel image. We cannot =20
> prevent
>  	 * kernel from using these memory, so we need to exclude these =20
> memory
>  	 * even if it is hotpluggable.
> +	 * Furthermore, to ensure the kernel has enough memory to boot, =20
> we make
> +	 * all the memory on the node which the kernel resides in
> +	 * un-hotpluggable.
>  	 */

Can you hot-unplug half a node? (Do you have a choice with the =20
granularity here?)

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
