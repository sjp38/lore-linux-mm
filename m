Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A870B6B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:29:55 -0500 (EST)
Date: Tue, 2 Mar 2010 22:29:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: Memory management woes - order 1 allocation failures
Message-ID: <20100302222933.GF11355@csn.ul.ie>
References: <alpine.DEB.2.00.1002261042020.7719@router.home> <84144f021002260917q61f7c255rf994425f3a613819@mail.gmail.com> <20100301103546.DD86.A69D9226@jp.fujitsu.com> <20100302172606.GA11355@csn.ul.ie> <20100302183451.75d44f03@lxorguk.ukuu.org.uk> <20100302191110.GB11355@csn.ul.ie> <20100302192942.GA2953@suse.de> <20100302211603.GD11355@csn.ul.ie> <20100302221751.20addf02@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100302221751.20addf02@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Greg KH <gregkh@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 10:17:51PM +0000, Alan Cox wrote:
> > -#define TTY_BUFFER_PAGE		((PAGE_SIZE  - 256) / 2)
> > +#define TTY_BUFFER_PAGE	(((PAGE_SIZE - sizeof(struct tty_buffer)) / 2) & ~0xFF)
> 
> Yes agreed I missed a '-1'
> 

Thanks.

Frans, would you mind testing your NAS box with the following patch applied
please? It should apply cleanly on top of 2.6.33-rc7. Thanks

==== CUT HERE ====
tty: Keep the default buffering to sub-page units
    
We allocate during interrupts so while our buffering is normally diced up
small anyway on some hardware at speed we can pressure the VM excessively
for page pairs. We don't really need big buffers to be linear so don't try
so hard.
    
In order to make this work well we will tidy up excess callers to request_room,
which cannot itself enforce this break up.

[mel@csn.ul.ie: Adjust TTY_BUFFER_PAGE to take padding into account]
Signed-off-by: Alan Cox <alan@linux.intel.com>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
--- 
 drivers/char/tty_buffer.c |    6 ++++--
 include/linux/tty.h       |   11 +++++++++++
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/char/tty_buffer.c b/drivers/char/tty_buffer.c
index 66fa4e1..f27c4d6 100644
--- a/drivers/char/tty_buffer.c
+++ b/drivers/char/tty_buffer.c
@@ -247,7 +247,8 @@ int tty_insert_flip_string(struct tty_struct *tty, const unsigned char *chars,
 {
 	int copied = 0;
 	do {
-		int space = tty_buffer_request_room(tty, size - copied);
+		int goal = min(size - copied, TTY_BUFFER_PAGE);
+		int space = tty_buffer_request_room(tty, goal);
 		struct tty_buffer *tb = tty->buf.tail;
 		/* If there is no space then tb may be NULL */
 		if (unlikely(space == 0))
@@ -283,7 +284,8 @@ int tty_insert_flip_string_flags(struct tty_struct *tty,
 {
 	int copied = 0;
 	do {
-		int space = tty_buffer_request_room(tty, size - copied);
+		int goal = min(size - copied, TTY_BUFFER_PAGE);
+		int space = tty_buffer_request_room(tty, goal);
 		struct tty_buffer *tb = tty->buf.tail;
 		/* If there is no space then tb may be NULL */
 		if (unlikely(space == 0))
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 6abfcf5..42f2076 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -68,6 +68,17 @@ struct tty_buffer {
 	unsigned long data[0];
 };
 
+/*
+ * We default to dicing tty buffer allocations to this many characters
+ * in order to avoid multiple page allocations. We know the size of
+ * tty_buffer itself but it must also be taken into account that the
+ * the buffer is 256 byte aligned. See tty_buffer_find for the allocation
+ * logic this must match
+ */
+
+#define TTY_BUFFER_PAGE	(((PAGE_SIZE - sizeof(struct tty_buffer)) / 2) & ~0xFF)
+
+
 struct tty_bufhead {
 	struct delayed_work work;
 	spinlock_t lock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
