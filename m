Received: by wr-out-0506.google.com with SMTP id 71so1860035wri
        for <linux-mm@kvack.org>; Tue, 20 Feb 2007 01:07:00 -0800 (PST)
Message-ID: <4df04b840702200106q670ff944k118d218fed17b884@mail.gmail.com>
Date: Tue, 20 Feb 2007 17:06:58 +0800
From: "yunfeng zhang" <zyf.zeroos@gmail.com>
Subject: Re: [PATCH 2.6.20-rc5 1/1] MM: enhance Linux swap subsystem
In-Reply-To: <4df04b840702122152o64b2d59cy53afcd43bb24cb7a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <4df04b840701212309l2a283357jbdaa88794e5208a7@mail.gmail.com>
	 <200701222300.41960.a1426z@gawab.com>
	 <4df04b840701222021w5e1aaab2if2ba7fc38d06d64b@mail.gmail.com>
	 <4df04b840701222108o6992933bied5fff8a525413@mail.gmail.com>
	 <Pine.LNX.4.64.0701242015090.1770@blonde.wat.veritas.com>
	 <4df04b840701301852i41687edfl1462c4ca3344431c@mail.gmail.com>
	 <Pine.LNX.4.64.0701312022340.26857@blonde.wat.veritas.com>
	 <4df04b840702122152o64b2d59cy53afcd43bb24cb7a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Following arithmetic is based on SwapSpace bitmap management which is discussed
in the postscript section of my patch. Two purposes are implemented, one is
allocating a group of fake continual swap entries, another is re-allocating
swap entries in stage 3 for such as series length is too short.


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
// 2 hardware cache line. You can also concentrate it to a hareware cache line.
char bits_per_short[256] = {
	8, 7, 7, 6, 7, 6, 6, 5,
	7, 6, 6, 5, 6, 5, 5, 4,
	7, 6, 6, 5, 6, 5, 5, 4,
	6, 5, 5, 4, 5, 4, 4, 3,
	7, 6, 6, 5, 6, 5, 5, 4,
	6, 5, 5, 4, 5, 4, 4, 3,
	6, 5, 5, 4, 5, 4, 4, 3,
	5, 4, 4, 3, 4, 3, 3, 2,
	7, 6, 6, 5, 6, 5, 5, 4,
	6, 5, 5, 4, 5, 4, 4, 3,
	6, 5, 5, 4, 5, 4, 4, 3,
	5, 4, 4, 3, 4, 3, 3, 2,
	6, 5, 5, 4, 5, 4, 4, 3,
	5, 4, 4, 3, 4, 3, 3, 2,
	5, 4, 4, 3, 4, 3, 3, 2,
	4, 3, 3, 2, 3, 2, 2, 1,
	7, 6, 6, 5, 6, 5, 5, 4,
	6, 5, 5, 4, 5, 4, 4, 3,
	6, 5, 5, 4, 5, 4, 4, 3,
	5, 4, 4, 3, 4, 3, 3, 2,
	6, 5, 5, 4, 5, 4, 4, 3,
	5, 4, 4, 3, 4, 3, 3, 2,
	5, 4, 4, 3, 4, 3, 3, 2,
	4, 3, 3, 2, 3, 2, 2, 1,
	6, 5, 5, 4, 5, 4, 4, 3,
	5, 4, 4, 3, 4, 3, 3, 2,
	5, 4, 4, 3, 4, 3, 3, 2,
	4, 3, 3, 2, 3, 2, 2, 1,
	5, 4, 4, 3, 4, 3, 3, 2,
	4, 3, 3, 2, 3, 2, 2, 1,
	4, 3, 3, 2, 3, 2, 2, 1,
	3, 2, 2, 1, 2, 1, 1, 0
};
unsigned char swap_bitmap[32];
// Allocate a group of fake continual swap entries.
int alloc(int size)
{
	int i, found = 0, result_offset;
	unsigned char a = 0, b = 0;
	for (i = 0; i < 32; i++) {
		b = bits_per_short[swap_bitmap[i]];
		if (a + b >= size) {
			found = 1;
			break;
		}
		a = b;
	}
	result_offset = i == 0 ? 0 : i - 1;
	result_offset = found ? result_offset : -1;
	return result_offset;
}
// Re-allocate in stage 3 if necessary.
int re_alloc(int position)
{
	int offset = position / 8;
	int a = offset == 0 ? 0 : offset - 1;
	int b = offset == 31 ? 31 : offset + 1;
	int i, empty_bits = 0;
	for (i = a; i <= b; i++) {
		empty_bits += bits_per_short[swap_bitmap[i]];
	}
	return empty_bits;
}
int main(int argc, char **argv)
{
	int i;
	for (i = 0; i < 32; i++) {
		swap_bitmap[i] = (unsigned char) (rand() % 0xff);
	}
	i = 9;
	int temp = alloc(i);
	temp = re_alloc(i);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
