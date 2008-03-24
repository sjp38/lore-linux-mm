Received: by gv-out-0910.google.com with SMTP id n8so450801gve.19
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 11:35:25 -0700 (PDT)
Message-ID: <4cefeab80803241135i70bd81e5od82b84685bc4dbb@mail.gmail.com>
Date: Tue, 25 Mar 2008 00:05:24 +0530
From: "Nitin Gupta" <nitingupta910@gmail.com>
Subject: Re: [PATCH 1/6] compcache: compressed RAM block device
In-Reply-To: <87a5b0800803240923m1ec9e343ld08c2828fe42e4e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200803242032.40589.nitingupta910@gmail.com>
	 <87a5b0800803240923m1ec9e343ld08c2828fe42e4e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Will Newton <will.newton@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 9:53 PM, Will Newton <will.newton@gmail.com> wrote:
>
> On Mon, Mar 24, 2008 at 3:02 PM, Nitin Gupta <nitingupta910@gmail.com> wrote:


>  >  diff --git a/drivers/block/Makefile b/drivers/block/Makefile
>  >  index 5e58430..b6d3dd2 100644
>  >  --- a/drivers/block/Makefile
>  >  +++ b/drivers/block/Makefile
>  >  @@ -12,6 +12,7 @@ obj-$(CONFIG_PS3_DISK)                += ps3disk.o
>  >   obj-$(CONFIG_ATARI_FLOPPY)     += ataflop.o
>  >   obj-$(CONFIG_AMIGA_Z2RAM)      += z2ram.o
>  >   obj-$(CONFIG_BLK_DEV_RAM)      += brd.o
>  >  +obj-$(CONFIG_BLK_DEV_COMPCACHE)        += compcache.o
>
>  Minor - this isn't in alphabetical order.

Intent here is to keep related things together. So, I have placed it
with generic ramdisk. This also seems to be convention used in this
file.

>  >  diff --git a/drivers/block/compcache.c b/drivers/block/compcache.c
>  >  new file mode 100644
>  >  index 0000000..4ffcd63
>  >  --- /dev/null
>  >  +++ b/drivers/block/compcache.c
>  >  @@ -0,0 +1,440 @@
>  >  +/*
>  >  + * Compressed RAM based swap device
>  >  + *
>  >  + * (C) Nitin Gupta
>
>  Should add a copyright year.
>

ok.

>  >  +#include <asm/string.h>
>
>  Should this be <linux/string.h>?
>

Yes. I will change this.


>  >  +/* Check if request is within bounds and page aligned */
>  >  +static inline int valid_swap_request(struct bio *bio)
>  >  +{
>  >  +       if (unlikely((bio->bi_sector >= compcache.size) ||
>  >  +                       (bio->bi_sector & (SECTORS_PER_PAGE - 1)) ||
>  >  +                       (bio->bi_vcnt != 1) ||
>  >  +                       (bio->bi_size != PAGE_SIZE) ||
>  >  +                       (bio->bi_io_vec[0].bv_offset != 0)))
>  >  +               return 0;
>  >  +       return 1;
>  >  +}
>
>  Probably unnecessary to mark this explicitly inline.
>
>

Probably yes. I am not sure.


>  >  +       /*
>  >  +        * It is named like this to prevent distro installers
>  >  +        * from offering compcache as installation target. They
>  >  +        * seem to ignore all devices beginning with 'ram'
>  >  +        */
>  >  +       sprintf(compcache.disk->disk_name, "%s", "ramzswap0");
>
>  I'm not sure the name makes it 100% obvious what the device is for.
>  You could use strcpy here also.
>

"z" == compress
and hence the name ramzswap :)


>  >  +       if (compcache.table[0].addr)
>  >  +               free_page((unsigned long)compcache.table[0].addr);
>  >  +       if (compcache.compress_workmem)
>  >  +               kfree(compcache.compress_workmem);
>  >  +       if (compcache.compress_buffer)
>  >  +               kfree(compcache.compress_buffer);
>  >  +       if (compcache.table)
>  >  +               vfree(compcache.table);
>
>  kfree() and vfree() may safely be called on NULL pointers.
>

I will remove these unnecessary checks then.


Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
