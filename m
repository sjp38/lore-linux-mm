Received: from fred.muc.de (exim@ns2075.munich.netsurf.de [195.180.232.75])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA21413
	for <linux-mm@kvack.org>; Mon, 31 May 1999 15:54:08 -0400
Date: Mon, 31 May 1999 21:54:38 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Application load times
Message-ID: <19990531215438.B3037@fred.muc.de>
References: <199905311911.PAA13206@bucky.physics.ncsu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199905311911.PAA13206@bucky.physics.ncsu.edu>; from Emil Briggs on Mon, May 31, 1999 at 09:11:08PM +0200
Sender: owner-linux-mm@kvack.org
To: Emil Briggs <briggs@bucky.physics.ncsu.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 1999 at 09:11:08PM +0200, Emil Briggs wrote:
> Are there any vm tuning parameters that can improve initial application
> load times on a freshly booted system? I'm asking since I found the
> following load times with Netscape Communicator and StarOffice.
> 
> 
> Communicator takes 14 seconds to load on a freshly booted system
> 
> On the other hand it takes 4 seconds to load using a program of this sort
> 
>   fd = open("/opt/netscape/netscape", O_RDONLY);
>   read(fd, buffer, 13858288);    
>   execv("/opt/netscape/netscape", argv);
> 
> With StarOffice the load time drops from 40 seconds to 15 seconds.
> 
> 
> The reason this came up is because I installed Linux on a friends
> computer who usually boots it a couple of times a day to check email,
> webbrowse or run StarOffice -- they immediately asked me why it
> was so slow. Since I know how they usually use their computer it was
> easy enough to remedy this with the little bit of code above. Anyway
> does anyone know if there a more general way of improving initial load
> times with some tuning parameters to the vm system?

The reason is that the read can use the disk bandwidth fully including
read-a-head, which the execv reads the block in the order the functions
which are called at loadup are laid out in the executable. This is especially
bad which C++ programs which usually have small constructors spread out
all over the file, which are called at boot up. The solution are special
programs which rearrange the executable and lay out the function on 
page boundaries to minimize the working set and load time.

These programs exist for most other OS with various names (e.g. pixie on
Irix). Not on Linux yet. Nat Friedman apparently presented a design for
"grope" on the LinuxExpo, but it isn't released yet.

2.2 made program loading already quite a bit faster by introducing readahead
for mmap. 



-Andi
-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
