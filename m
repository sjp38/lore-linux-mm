Subject: Re: 2.6.0-test9-mm1 -- DIO and AIO Tests results
From: Daniel McNeil <daniel@osdl.org>
In-Reply-To: <20031030011810.633a8f5b.akpm@osdl.org>
References: <20031030011810.633a8f5b.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1067643174.2558.13.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Date: 31 Oct 2003 15:32:54 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Suparna Bhattacharya <suparna@in.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "linux-aio@kvack.org" <linux-aio@kvack.org>
List-ID: <linux-mm.kvack.org>

I have re-run the AIO tests on test9, test9-mm1, and
test9-mm1+retry-based-aio-dio-patch;

I ran the tests on an ext3 file system running on a 2-proc XEON 
to an ide disk drive.

2.6.0-test9:
===========
As reported earlier, test9 is seeing uninitialized data and the
kiocbs are being modified after free:

$ dio_sparse
non zero buffer at buf[0] => 0xaa,aa,aa,aa
non-zero read at offset 69533696

$ aiodio_sparse
non zero buffer at buf[0] => 0xaa,aa,aa,aa
non-zero read at offset 81854464

With slab debug on, test9 still gets

slab error in check_poison_obj(): cache `kiocb': object was modified after freeing


2.6.0-test9-mm1:
===============

dio_spares - run without seeing uninitialized data 

aiodio_sparse - get AIO errors and these kernel messages:

aio_run_iocb: iocb->ki_retry = NULL
Maximal retry count.  Bytes done 0
Slab corruption: start=e8676d68, expend=e8676e37, problemat=e8676d68
Last user: [<c018f883>](__aio_put_req+0xa8/0x1b3)
...
slab error in check_poison_obj(): cache `kiocb': object was modified after freeing

	
2.6.0-test9-mm1+retry-based-aio-dio-patch (from suparna)
=======================================================

dio_sparse - runs successfully and does not see uninitialized data

aiodio_sparse - runs successfully, does not see uninitialized data,
	and no slab corruption.


As before, my updated tests are here:
http://developer.osdl.org/daniel/AIO/TESTS/


Daniel


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
