Date: Thu, 2 Nov 2000 16:07:08 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#05, -ENXIO beyond device EOF
Message-ID: <20001102160708.H1876@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="N8ia4yKhAKKETby7"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--N8ia4yKhAKKETby7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

Final pending kiobuf fix for now: return ENXIO on requests for
non-zero data reads/writes beyond the end of a block device,
consistent with SU's


      [ENXIO]
            A request was made of a non-existent device, or the
	    request was outside the capabilities of the device. 

I've had this requested from other vendors who expect this behaviour
on raw devices, so it seems to be the accepted behaviour.

Return success on zero-byte requests --- SU and POSIX are picky about
that.

--Stephen

--N8ia4yKhAKKETby7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="05-enxio.diff"

diff -ru linux-2.4.0-test10.kio.04/drivers/char/raw.c linux-2.4.0-test10.kio.05/drivers/char/raw.c
--- linux-2.4.0-test10.kio.04/drivers/char/raw.c	Thu Nov  2 12:08:54 2000
+++ linux-2.4.0-test10.kio.05/drivers/char/raw.c	Thu Nov  2 14:19:32 2000
@@ -277,8 +277,12 @@
 	
 	if ((*offp & sector_mask) || (size & sector_mask))
 		return -EINVAL;
-	if ((*offp >> sector_bits) > limit)
+	if ((*offp >> sector_bits) >= limit) {
+		if (size) {
+			return -ENXIO;
+		}
 		return 0;
+	}
 
 	/* 
 	 * We'll just use one kiobuf

--N8ia4yKhAKKETby7--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
