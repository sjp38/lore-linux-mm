Received: from localhost (riel@localhost)
	by duckman.conectiva (8.9.3/8.8.7) with ESMTP id QAA06594
	for <linux-mm@kvack.org>; Mon, 24 Apr 2000 16:54:38 -0300
Date: Mon, 24 Apr 2000 16:54:38 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Reply-To: riel@nl.linux.org
Subject: pressuring dirty pages (2.3.99-pre6)
Message-ID: <Pine.LNX.4.21.0004241650140.5572-200000@duckman.conectiva>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463795457-1864175454-956606078=:5572"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

---1463795457-1864175454-956606078=:5572
Content-Type: TEXT/PLAIN; charset=US-ASCII

Hi,

I've been trying to fix the VM balance for a week or so now,
and things are mostly fixed except for one situation.

If there is a *heavy* write going on and the data is in the
page cache only .. ie. no buffer heads available, then the
page cache will grow almost without bounds and kswapd and
the rest of the system will basically spin in shrink_mmap()...

What mechanism do we use to flush back dirty pages from eg.
mmap()s?  How could I push those pages to disk the way we
do with buffers (by waking up bdflush)?

(yes, this is a big bug, please try the attached program by
Juan Quintela and set the #defines as wanted .. it'll make
painfully clear that this bug exists and should be fixed)

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

---1463795457-1864175454-956606078=:5572
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="qmtest.c"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.21.0004241654380.5572@duckman.conectiva>
Content-Description: qmtest.c
Content-Disposition: attachment; filename="qmtest.c"

LyoNCiAqIE1lbW9yeSB0ZXN0ZXIgYnkgUXVpbnRlbGEuDQogKi8NCiNpbmNs
dWRlIDxzeXMvdHlwZXMuaD4NCiNpbmNsdWRlIDxzeXMvc3RhdC5oPg0KI2lu
Y2x1ZGUgPGZjbnRsLmg+DQojaW5jbHVkZSA8c3lzL21tYW4uaD4NCiNpbmNs
dWRlIDxzdGRsaWIuaD4NCiNpbmNsdWRlIDxzdGRpby5oPg0KI2luY2x1ZGUg
PHVuaXN0ZC5oPg0KDQojZGVmaW5lIEZJTEVOQU1FICIvdG1wL3Rlc3Rpbmdf
ZmlsZSINCi8qIFB1dCBoZXJlIDJ0aW1lcyB5b3VyIG1lbW9yeSBvciBsZXNz
ICovDQojZGVmaW5lIFNJWkUgICAgICgxMjggKiAxMDI0ICogMTAyNCkgDQoN
Cg0Kdm9pZCBlcnJvcl9zdHJpbmcoY2hhciAqbXNnKQ0Kew0KICAgICAgICBw
ZXJyb3IobXNnKTsNCiAgICAgICAgZXhpdChFWElUX0ZBSUxVUkUpOw0KfQ0K
DQppbnQgbWFpbihpbnQgYXJnYywgY2hhciAqIGFyZ3ZbXSkNCnsNCiAgICAg
ICAgY2hhciAqYXJyYXk7DQogICAgICAgIGludCBpOw0KICAgICAgICBpbnQg
ZmQgPSBvcGVuKEZJTEVOQU1FLCBPX1JEV1IgfCBPX0NSRUFULCAwNjY2KTsN
CiAgICAgICAgaWYgKGZkID09IC0xKQ0KICAgICAgICAgICAgICAgIGVycm9y
X3N0cmluZygiUHJvYmxlbXMgb3BlbmluZyB0aGUgZmlsZSIpOw0KDQogICAg
ICAgIGlmIChsc2VlayhmZCwgU0laRSwgU0VFS19TRVQpICE9IFNJWkUpDQog
ICAgICAgICAgICAgICAgZXJyb3Jfc3RyaW5nKCJQcm9ibGVtcyBkb2luZyB0
aGUgbHNlZWsiKTsNCg0KICAgICAgICBpZiAod3JpdGUoZmQsIlwwIiwxKSAh
PTEpDQogICAgICAgICAgICAgICAgZXJyb3Jfc3RyaW5nKCJQcm9ibGVtcyB3
cml0aW5nIik7DQogDQogICAgICAgIGFycmF5ID0gbW1hcCgwLCBTSVpFLCBQ
Uk9UX1dSSVRFLCBNQVBfU0hBUkVELGZkLDApOw0KICAgICAgICBpZiAoYXJy
YXkgPT0gTUFQX0ZBSUxFRCkNCiAgICAgICAgICAgICAgICBlcnJvcl9zdHJp
bmcoIlRoZSBtbWFwIGhhcyBmYWlsZWQiKTsNCiAgICAgICAgDQogICAgICAg
IGZvcihpID0gMDsgaSA8IFNJWkU7IGkrKykgew0KICAgICAgICAgICAgICAg
IGFycmF5W2ldID0gaTsNCiAgICAgICAgfSANCiAgICAgICAgbXN5bmMoYXJy
YXksIFNJWkUsIE1TX1NZTkMpOw0KICAgICAgICBjbG9zZShmZCk7DQogICAg
ICAgIGV4aXQoRVhJVF9TVUNDRVNTKTsNCn0NCg==
---1463795457-1864175454-956606078=:5572--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
