Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0D96B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 02:24:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id j69-v6so2995674lfg.6
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 23:24:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a10sor2635086ljj.79.2018.04.22.23.24.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 22 Apr 2018 23:24:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201804231148.J8swjvzw%fengguang.wu@intel.com>
References: <20180421171442.GA17919@jordon-HP-15-Notebook-PC> <201804231148.J8swjvzw%fengguang.wu@intel.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Mon, 23 Apr 2018 11:53:59 +0530
Message-ID: <CAFqt6za-KBJ6rZ-yykb1aRZTEP89eMbXvGfcMUwjRVU5A6hwvw@mail.gmail.com>
Subject: Re: [PATCH v2] fs: dax: Adding new return type vm_fault_t
Content-Type: multipart/alternative; boundary="001a113db2fa6962fc056a7e1569"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, kbuild-all@01.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, mawilcox@microsoft.com

--001a113db2fa6962fc056a7e1569
Content-Type: text/plain; charset="UTF-8"

Patch v3 is the latest one which need to be tested. Please ignore v2.

On 23-Apr-2018 10:59 AM, "kbuild test robot" <lkp@intel.com> wrote:
>
> Hi Souptick,
>
> Thank you for the patch! Yet something to improve:
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.17-rc2 next-20180420]
> [if your patch is applied to the wrong git tree, please drop us a note to
help improve the system]
>
> url:
https://github.com/0day-ci/linux/commits/Souptick-Joarder/fs-dax-Adding-new-return-type-vm_fault_t/20180423-102814
> config: i386-randconfig-x006-201816 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-16) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All errors (new ones prefixed by >>):
>
>    fs/dax.c: In function 'dax_iomap_pte_fault':
> >> fs/dax.c:1265:10: error: implicit declaration of function
'vmf_insert_mixed_mkwrite'; did you mean 'vm_insert_mixed_mkwrite'?
[-Werror=implicit-function-declaration]
>        ret = vmf_insert_mixed_mkwrite(vma, vaddr, pfn);
>              ^~~~~~~~~~~~~~~~~~~~~~~~
>              vm_insert_mixed_mkwrite
>    cc1: some warnings being treated as errors
>
> vim +1265 fs/dax.c
>
>   1134
>   1135  static vm_fault_t dax_iomap_pte_fault(struct vm_fault *vmf, pfn_t
*pfnp,
>   1136                                 int *iomap_errp, const struct
iomap_ops *ops)
>   1137  {
>   1138          struct vm_area_struct *vma = vmf->vma;
>   1139          struct address_space *mapping = vma->vm_file->f_mapping;
>   1140          struct inode *inode = mapping->host;
>   1141          unsigned long vaddr = vmf->address;
>   1142          loff_t pos = (loff_t)vmf->pgoff << PAGE_SHIFT;
>   1143          struct iomap iomap = { 0 };
>   1144          unsigned flags = IOMAP_FAULT;
>   1145          int error, major = 0;
>   1146          bool write = vmf->flags & FAULT_FLAG_WRITE;
>   1147          bool sync;
>   1148          vm_fault_t ret = 0;
>   1149          void *entry;
>   1150          pfn_t pfn;
>   1151
>   1152          trace_dax_pte_fault(inode, vmf, ret);
>   1153          /*
>   1154           * Check whether offset isn't beyond end of file now.
Caller is supposed
>   1155           * to hold locks serializing us with truncate / punch
hole so this is
>   1156           * a reliable test.
>   1157           */
>   1158          if (pos >= i_size_read(inode)) {
>   1159                  ret = VM_FAULT_SIGBUS;
>   1160                  goto out;
>   1161          }
>   1162
>   1163          if (write && !vmf->cow_page)
>   1164                  flags |= IOMAP_WRITE;
>   1165
>   1166          entry = grab_mapping_entry(mapping, vmf->pgoff, 0);
>   1167          if (IS_ERR(entry)) {
>   1168                  ret = dax_fault_return(PTR_ERR(entry));
>   1169                  goto out;
>   1170          }
>   1171
>   1172          /*
>   1173           * It is possible, particularly with mixed reads & writes
to private
>   1174           * mappings, that we have raced with a PMD fault that
overlaps with
>   1175           * the PTE we need to set up.  If so just return and the
fault will be
>   1176           * retried.
>   1177           */
>   1178          if (pmd_trans_huge(*vmf->pmd) || pmd_devmap(*vmf->pmd)) {
>   1179                  ret = VM_FAULT_NOPAGE;
>   1180                  goto unlock_entry;
>   1181          }
>   1182
>   1183          /*
>   1184           * Note that we don't bother to use iomap_apply here: DAX
required
>   1185           * the file system block size to be equal the page size,
which means
>   1186           * that we never have to deal with more than a single
extent here.
>   1187           */
>   1188          error = ops->iomap_begin(inode, pos, PAGE_SIZE, flags,
&iomap);
>   1189          if (iomap_errp)
>   1190                  *iomap_errp = error;
>   1191          if (error) {
>   1192                  ret = dax_fault_return(error);
>   1193                  goto unlock_entry;
>   1194          }
>   1195          if (WARN_ON_ONCE(iomap.offset + iomap.length < pos +
PAGE_SIZE)) {
>   1196                  error = -EIO;   /* fs corruption? */
>   1197                  goto error_finish_iomap;
>   1198          }
>   1199
>   1200          if (vmf->cow_page) {
>   1201                  sector_t sector = dax_iomap_sector(&iomap, pos);
>   1202
>   1203                  switch (iomap.type) {
>   1204                  case IOMAP_HOLE:
>   1205                  case IOMAP_UNWRITTEN:
>   1206                          clear_user_highpage(vmf->cow_page, vaddr);
>   1207                          break;
>   1208                  case IOMAP_MAPPED:
>   1209                          error = copy_user_dax(iomap.bdev,
iomap.dax_dev,
>   1210                                          sector, PAGE_SIZE,
vmf->cow_page, vaddr);
>   1211                          break;
>   1212                  default:
>   1213                          WARN_ON_ONCE(1);
>   1214                          error = -EIO;
>   1215                          break;
>   1216                  }
>   1217
>   1218                  if (error)
>   1219                          goto error_finish_iomap;
>   1220
>   1221                  __SetPageUptodate(vmf->cow_page);
>   1222                  ret = finish_fault(vmf);
>   1223                  if (!ret)
>   1224                          ret = VM_FAULT_DONE_COW;
>   1225                  goto finish_iomap;
>   1226          }
>   1227
>   1228          sync = dax_fault_is_synchronous(flags, vma, &iomap);
>   1229
>   1230          switch (iomap.type) {
>   1231          case IOMAP_MAPPED:
>   1232                  if (iomap.flags & IOMAP_F_NEW) {
>   1233                          count_vm_event(PGMAJFAULT);
>   1234                          count_memcg_event_mm(vma->vm_mm,
PGMAJFAULT);
>   1235                          major = VM_FAULT_MAJOR;
>   1236                  }
>   1237                  error = dax_iomap_pfn(&iomap, pos, PAGE_SIZE,
&pfn);
>   1238                  if (error < 0)
>   1239                          goto error_finish_iomap;
>   1240
>   1241                  entry = dax_insert_mapping_entry(mapping, vmf,
entry, pfn,
>   1242                                                   0, write &&
!sync);
>   1243                  if (IS_ERR(entry)) {
>   1244                          error = PTR_ERR(entry);
>   1245                          goto error_finish_iomap;
>   1246                  }
>   1247
>   1248                  /*
>   1249                   * If we are doing synchronous page fault and
inode needs fsync,
>   1250                   * we can insert PTE into page tables only after
that happens.
>   1251                   * Skip insertion for now and return the pfn so
that caller can
>   1252                   * insert it after fsync is done.
>   1253                   */
>   1254                  if (sync) {
>   1255                          if (WARN_ON_ONCE(!pfnp)) {
>   1256                                  error = -EIO;
>   1257                                  goto error_finish_iomap;
>   1258                          }
>   1259                          *pfnp = pfn;
>   1260                          ret = VM_FAULT_NEEDDSYNC | major;
>   1261                          goto finish_iomap;
>   1262                  }
>   1263                  trace_dax_insert_mapping(inode, vmf, entry);
>   1264                  if (write)
> > 1265                          ret = vmf_insert_mixed_mkwrite(vma,
vaddr, pfn);
>   1266                  else
>   1267                          ret = vmf_insert_mixed(vma, vaddr, pfn);
>   1268
>   1269                  goto finish_iomap;
>   1270          case IOMAP_UNWRITTEN:
>   1271          case IOMAP_HOLE:
>   1272                  if (!write) {
>   1273                          ret = dax_load_hole(mapping, entry, vmf);
>   1274                          goto finish_iomap;
>   1275                  }
>   1276                  /*FALLTHRU*/
>   1277          default:
>   1278                  WARN_ON_ONCE(1);
>   1279                  error = -EIO;
>   1280                  break;
>   1281          }
>   1282
>   1283   error_finish_iomap:
>   1284          ret = dax_fault_return(error) | major;
>   1285   finish_iomap:
>   1286          if (ops->iomap_end) {
>   1287                  int copied = PAGE_SIZE;
>   1288
>   1289                  if (ret & VM_FAULT_ERROR)
>   1290                          copied = 0;
>   1291                  /*
>   1292                   * The fault is done by now and there's no way
back (other
>   1293                   * thread may be already happily using PTE we
have installed).
>   1294                   * Just ignore error from ->iomap_end since we
cannot do much
>   1295                   * with it.
>   1296                   */
>   1297                  ops->iomap_end(inode, pos, PAGE_SIZE, copied,
flags, &iomap);
>   1298          }
>   1299   unlock_entry:
>   1300          put_locked_mapping_entry(mapping, vmf->pgoff);
>   1301   out:
>   1302          trace_dax_pte_fault_done(inode, vmf, ret);
>   1303          return ret;
>   1304  }
>   1305
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology
Center
> https://lists.01.org/pipermail/kbuild-all                   Intel
Corporation

--001a113db2fa6962fc056a7e1569
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: base64

PHAgZGlyPSJsdHIiPlBhdGNoIHYzIGlzIHRoZSBsYXRlc3Qgb25lIHdoaWNoIG5lZWQgdG8gYmUg
dGVzdGVkLiBQbGVhc2UgaWdub3JlIHYyLjwvcD4NCjxwIGRpcj0ibHRyIj5PbiAyMy1BcHItMjAx
OCAxMDo1OSBBTSwgJnF1b3Q7a2J1aWxkIHRlc3Qgcm9ib3QmcXVvdDsgJmx0OzxhIGhyZWY9Im1h
aWx0bzpsa3BAaW50ZWwuY29tIj5sa3BAaW50ZWwuY29tPC9hPiZndDsgd3JvdGU6PGJyPg0KJmd0
Ozxicj4NCiZndDsgSGkgU291cHRpY2ssPGJyPg0KJmd0Ozxicj4NCiZndDsgVGhhbmsgeW91IGZv
ciB0aGUgcGF0Y2ghIFlldCBzb21ldGhpbmcgdG8gaW1wcm92ZTo8YnI+DQomZ3Q7PGJyPg0KJmd0
OyBbYXV0byBidWlsZCB0ZXN0IEVSUk9SIG9uIGxpbnVzL21hc3Rlcl08YnI+DQomZ3Q7IFthbHNv
IGJ1aWxkIHRlc3QgRVJST1Igb24gdjQuMTctcmMyIG5leHQtMjAxODA0MjBdPGJyPg0KJmd0OyBb
aWYgeW91ciBwYXRjaCBpcyBhcHBsaWVkIHRvIHRoZSB3cm9uZyBnaXQgdHJlZSwgcGxlYXNlIGRy
b3AgdXMgYSBub3RlIHRvIGhlbHAgaW1wcm92ZSB0aGUgc3lzdGVtXTxicj4NCiZndDs8YnI+DQom
Z3Q7IHVybDrCoCDCoCA8YSBocmVmPSJodHRwczovL2dpdGh1Yi5jb20vMGRheS1jaS9saW51eC9j
b21taXRzL1NvdXB0aWNrLUpvYXJkZXIvZnMtZGF4LUFkZGluZy1uZXctcmV0dXJuLXR5cGUtdm1f
ZmF1bHRfdC8yMDE4MDQyMy0xMDI4MTQiPmh0dHBzOi8vZ2l0aHViLmNvbS8wZGF5LWNpL2xpbnV4
L2NvbW1pdHMvU291cHRpY2stSm9hcmRlci9mcy1kYXgtQWRkaW5nLW5ldy1yZXR1cm4tdHlwZS12
bV9mYXVsdF90LzIwMTgwNDIzLTEwMjgxNDwvYT48YnI+DQomZ3Q7IGNvbmZpZzogaTM4Ni1yYW5k
Y29uZmlnLXgwMDYtMjAxODE2IChhdHRhY2hlZCBhcyAuY29uZmlnKTxicj4NCiZndDsgY29tcGls
ZXI6IGdjYy03IChEZWJpYW4gNy4zLjAtMTYpIDcuMy4wPGJyPg0KJmd0OyByZXByb2R1Y2U6PGJy
Pg0KJmd0OyDCoCDCoCDCoCDCoCAjIHNhdmUgdGhlIGF0dGFjaGVkIC5jb25maWcgdG8gbGludXgg
YnVpbGQgdHJlZTxicj4NCiZndDsgwqAgwqAgwqAgwqAgbWFrZSBBUkNIPWkzODYgPGJyPg0KJmd0
Ozxicj4NCiZndDsgQWxsIGVycm9ycyAobmV3IG9uZXMgcHJlZml4ZWQgYnkgJmd0OyZndDspOjxi
cj4NCiZndDs8YnI+DQomZ3Q7IMKgIMKgZnMvZGF4LmM6IEluIGZ1bmN0aW9uICYjMzk7ZGF4X2lv
bWFwX3B0ZV9mYXVsdCYjMzk7Ojxicj4NCiZndDsgJmd0OyZndDsgZnMvZGF4LmM6MTI2NToxMDog
ZXJyb3I6IGltcGxpY2l0IGRlY2xhcmF0aW9uIG9mIGZ1bmN0aW9uICYjMzk7dm1mX2luc2VydF9t
aXhlZF9ta3dyaXRlJiMzOTs7IGRpZCB5b3UgbWVhbiAmIzM5O3ZtX2luc2VydF9taXhlZF9ta3dy
aXRlJiMzOTs/IFstV2Vycm9yPWltcGxpY2l0LWZ1bmN0aW9uLWRlY2xhcmF0aW9uXTxicj4NCiZn
dDsgwqAgwqAgwqAgwqByZXQgPSB2bWZfaW5zZXJ0X21peGVkX21rd3JpdGUodm1hLCB2YWRkciwg
cGZuKTs8YnI+DQomZ3Q7IMKgIMKgIMKgIMKgIMKgIMKgIMKgXn5+fn5+fn5+fn5+fn5+fn5+fn5+
fn5+PGJyPg0KJmd0OyDCoCDCoCDCoCDCoCDCoCDCoCDCoHZtX2luc2VydF9taXhlZF9ta3dyaXRl
PGJyPg0KJmd0OyDCoCDCoGNjMTogc29tZSB3YXJuaW5ncyBiZWluZyB0cmVhdGVkIGFzIGVycm9y
czxicj4NCiZndDs8YnI+DQomZ3Q7IHZpbSArMTI2NSBmcy9kYXguYzxicj4NCiZndDs8YnI+DQom
Z3Q7IMKgIDExMzTCoCA8YnI+DQomZ3Q7IMKgIDExMzXCoCBzdGF0aWMgdm1fZmF1bHRfdCBkYXhf
aW9tYXBfcHRlX2ZhdWx0KHN0cnVjdCB2bV9mYXVsdCAqdm1mLCBwZm5fdCAqcGZucCw8YnI+DQom
Z3Q7IMKgIDExMzbCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoGludCAqaW9tYXBfZXJycCwgY29uc3Qgc3RydWN0IGlvbWFwX29wcyAqb3BzKTxicj4NCiZn
dDsgwqAgMTEzN8KgIHs8YnI+DQomZ3Q7IMKgIDExMzjCoCDCoCDCoCDCoCDCoCBzdHJ1Y3Qgdm1f
YXJlYV9zdHJ1Y3QgKnZtYSA9IHZtZi0mZ3Q7dm1hOzxicj4NCiZndDsgwqAgMTEzOcKgIMKgIMKg
IMKgIMKgIHN0cnVjdCBhZGRyZXNzX3NwYWNlICptYXBwaW5nID0gdm1hLSZndDt2bV9maWxlLSZn
dDtmX21hcHBpbmc7PGJyPg0KJmd0OyDCoCAxMTQwwqAgwqAgwqAgwqAgwqAgc3RydWN0IGlub2Rl
ICppbm9kZSA9IG1hcHBpbmctJmd0O2hvc3Q7PGJyPg0KJmd0OyDCoCAxMTQxwqAgwqAgwqAgwqAg
wqAgdW5zaWduZWQgbG9uZyB2YWRkciA9IHZtZi0mZ3Q7YWRkcmVzczs8YnI+DQomZ3Q7IMKgIDEx
NDLCoCDCoCDCoCDCoCDCoCBsb2ZmX3QgcG9zID0gKGxvZmZfdCl2bWYtJmd0O3Bnb2ZmICZsdDsm
bHQ7IFBBR0VfU0hJRlQ7PGJyPg0KJmd0OyDCoCAxMTQzwqAgwqAgwqAgwqAgwqAgc3RydWN0IGlv
bWFwIGlvbWFwID0geyAwIH07PGJyPg0KJmd0OyDCoCAxMTQ0wqAgwqAgwqAgwqAgwqAgdW5zaWdu
ZWQgZmxhZ3MgPSBJT01BUF9GQVVMVDs8YnI+DQomZ3Q7IMKgIDExNDXCoCDCoCDCoCDCoCDCoCBp
bnQgZXJyb3IsIG1ham9yID0gMDs8YnI+DQomZ3Q7IMKgIDExNDbCoCDCoCDCoCDCoCDCoCBib29s
IHdyaXRlID0gdm1mLSZndDtmbGFncyAmYW1wOyBGQVVMVF9GTEFHX1dSSVRFOzxicj4NCiZndDsg
wqAgMTE0N8KgIMKgIMKgIMKgIMKgIGJvb2wgc3luYzs8YnI+DQomZ3Q7IMKgIDExNDjCoCDCoCDC
oCDCoCDCoCB2bV9mYXVsdF90IHJldCA9IDA7PGJyPg0KJmd0OyDCoCAxMTQ5wqAgwqAgwqAgwqAg
wqAgdm9pZCAqZW50cnk7PGJyPg0KJmd0OyDCoCAxMTUwwqAgwqAgwqAgwqAgwqAgcGZuX3QgcGZu
Ozxicj4NCiZndDsgwqAgMTE1McKgIDxicj4NCiZndDsgwqAgMTE1MsKgIMKgIMKgIMKgIMKgIHRy
YWNlX2RheF9wdGVfZmF1bHQoaW5vZGUsIHZtZiwgcmV0KTs8YnI+DQomZ3Q7IMKgIDExNTPCoCDC
oCDCoCDCoCDCoCAvKjxicj4NCiZndDsgwqAgMTE1NMKgIMKgIMKgIMKgIMKgIMKgKiBDaGVjayB3
aGV0aGVyIG9mZnNldCBpc24mIzM5O3QgYmV5b25kIGVuZCBvZiBmaWxlIG5vdy4gQ2FsbGVyIGlz
IHN1cHBvc2VkPGJyPg0KJmd0OyDCoCAxMTU1wqAgwqAgwqAgwqAgwqAgwqAqIHRvIGhvbGQgbG9j
a3Mgc2VyaWFsaXppbmcgdXMgd2l0aCB0cnVuY2F0ZSAvIHB1bmNoIGhvbGUgc28gdGhpcyBpczxi
cj4NCiZndDsgwqAgMTE1NsKgIMKgIMKgIMKgIMKgIMKgKiBhIHJlbGlhYmxlIHRlc3QuPGJyPg0K
Jmd0OyDCoCAxMTU3wqAgwqAgwqAgwqAgwqAgwqAqLzxicj4NCiZndDsgwqAgMTE1OMKgIMKgIMKg
IMKgIMKgIGlmIChwb3MgJmd0Oz0gaV9zaXplX3JlYWQoaW5vZGUpKSB7PGJyPg0KJmd0OyDCoCAx
MTU5wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgcmV0ID0gVk1fRkFVTFRfU0lHQlVTOzxicj4N
CiZndDsgwqAgMTE2MMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGdvdG8gb3V0Ozxicj4NCiZn
dDsgwqAgMTE2McKgIMKgIMKgIMKgIMKgIH08YnI+DQomZ3Q7IMKgIDExNjLCoCA8YnI+DQomZ3Q7
IMKgIDExNjPCoCDCoCDCoCDCoCDCoCBpZiAod3JpdGUgJmFtcDsmYW1wOyAhdm1mLSZndDtjb3df
cGFnZSk8YnI+DQomZ3Q7IMKgIDExNjTCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBmbGFncyB8
PSBJT01BUF9XUklURTs8YnI+DQomZ3Q7IMKgIDExNjXCoCA8YnI+DQomZ3Q7IMKgIDExNjbCoCDC
oCDCoCDCoCDCoCBlbnRyeSA9IGdyYWJfbWFwcGluZ19lbnRyeShtYXBwaW5nLCB2bWYtJmd0O3Bn
b2ZmLCAwKTs8YnI+DQomZ3Q7IMKgIDExNjfCoCDCoCDCoCDCoCDCoCBpZiAoSVNfRVJSKGVudHJ5
KSkgezxicj4NCiZndDsgwqAgMTE2OMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHJldCA9IGRh
eF9mYXVsdF9yZXR1cm4oUFRSX0VSUihlbnRyeSkpOzxicj4NCiZndDsgwqAgMTE2OcKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIGdvdG8gb3V0Ozxicj4NCiZndDsgwqAgMTE3MMKgIMKgIMKgIMKg
IMKgIH08YnI+DQomZ3Q7IMKgIDExNzHCoCA8YnI+DQomZ3Q7IMKgIDExNzLCoCDCoCDCoCDCoCDC
oCAvKjxicj4NCiZndDsgwqAgMTE3M8KgIMKgIMKgIMKgIMKgIMKgKiBJdCBpcyBwb3NzaWJsZSwg
cGFydGljdWxhcmx5IHdpdGggbWl4ZWQgcmVhZHMgJmFtcDsgd3JpdGVzIHRvIHByaXZhdGU8YnI+
DQomZ3Q7IMKgIDExNzTCoCDCoCDCoCDCoCDCoCDCoCogbWFwcGluZ3MsIHRoYXQgd2UgaGF2ZSBy
YWNlZCB3aXRoIGEgUE1EIGZhdWx0IHRoYXQgb3ZlcmxhcHMgd2l0aDxicj4NCiZndDsgwqAgMTE3
NcKgIMKgIMKgIMKgIMKgIMKgKiB0aGUgUFRFIHdlIG5lZWQgdG8gc2V0IHVwLsKgIElmIHNvIGp1
c3QgcmV0dXJuIGFuZCB0aGUgZmF1bHQgd2lsbCBiZTxicj4NCiZndDsgwqAgMTE3NsKgIMKgIMKg
IMKgIMKgIMKgKiByZXRyaWVkLjxicj4NCiZndDsgwqAgMTE3N8KgIMKgIMKgIMKgIMKgIMKgKi88
YnI+DQomZ3Q7IMKgIDExNzjCoCDCoCDCoCDCoCDCoCBpZiAocG1kX3RyYW5zX2h1Z2UoKnZtZi0m
Z3Q7cG1kKSB8fCBwbWRfZGV2bWFwKCp2bWYtJmd0O3BtZCkpIHs8YnI+DQomZ3Q7IMKgIDExNznC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXQgPSBWTV9GQVVMVF9OT1BBR0U7PGJyPg0KJmd0
OyDCoCAxMTgwwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgZ290byB1bmxvY2tfZW50cnk7PGJy
Pg0KJmd0OyDCoCAxMTgxwqAgwqAgwqAgwqAgwqAgfTxicj4NCiZndDsgwqAgMTE4MsKgIDxicj4N
CiZndDsgwqAgMTE4M8KgIMKgIMKgIMKgIMKgIC8qPGJyPg0KJmd0OyDCoCAxMTg0wqAgwqAgwqAg
wqAgwqAgwqAqIE5vdGUgdGhhdCB3ZSBkb24mIzM5O3QgYm90aGVyIHRvIHVzZSBpb21hcF9hcHBs
eSBoZXJlOiBEQVggcmVxdWlyZWQ8YnI+DQomZ3Q7IMKgIDExODXCoCDCoCDCoCDCoCDCoCDCoCog
dGhlIGZpbGUgc3lzdGVtIGJsb2NrIHNpemUgdG8gYmUgZXF1YWwgdGhlIHBhZ2Ugc2l6ZSwgd2hp
Y2ggbWVhbnM8YnI+DQomZ3Q7IMKgIDExODbCoCDCoCDCoCDCoCDCoCDCoCogdGhhdCB3ZSBuZXZl
ciBoYXZlIHRvIGRlYWwgd2l0aCBtb3JlIHRoYW4gYSBzaW5nbGUgZXh0ZW50IGhlcmUuPGJyPg0K
Jmd0OyDCoCAxMTg3wqAgwqAgwqAgwqAgwqAgwqAqLzxicj4NCiZndDsgwqAgMTE4OMKgIMKgIMKg
IMKgIMKgIGVycm9yID0gb3BzLSZndDtpb21hcF9iZWdpbihpbm9kZSwgcG9zLCBQQUdFX1NJWkUs
IGZsYWdzLCAmYW1wO2lvbWFwKTs8YnI+DQomZ3Q7IMKgIDExODnCoCDCoCDCoCDCoCDCoCBpZiAo
aW9tYXBfZXJycCk8YnI+DQomZ3Q7IMKgIDExOTDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCAq
aW9tYXBfZXJycCA9IGVycm9yOzxicj4NCiZndDsgwqAgMTE5McKgIMKgIMKgIMKgIMKgIGlmIChl
cnJvcikgezxicj4NCiZndDsgwqAgMTE5MsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHJldCA9
IGRheF9mYXVsdF9yZXR1cm4oZXJyb3IpOzxicj4NCiZndDsgwqAgMTE5M8KgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIGdvdG8gdW5sb2NrX2VudHJ5Ozxicj4NCiZndDsgwqAgMTE5NMKgIMKgIMKg
IMKgIMKgIH08YnI+DQomZ3Q7IMKgIDExOTXCoCDCoCDCoCDCoCDCoCBpZiAoV0FSTl9PTl9PTkNF
KGlvbWFwLm9mZnNldCArIGlvbWFwLmxlbmd0aCAmbHQ7IHBvcyArIFBBR0VfU0laRSkpIHs8YnI+
DQomZ3Q7IMKgIDExOTbCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBlcnJvciA9IC1FSU87wqAg
wqAvKiBmcyBjb3JydXB0aW9uPyAqLzxicj4NCiZndDsgwqAgMTE5N8KgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIGdvdG8gZXJyb3JfZmluaXNoX2lvbWFwOzxicj4NCiZndDsgwqAgMTE5OMKgIMKg
IMKgIMKgIMKgIH08YnI+DQomZ3Q7IMKgIDExOTnCoCA8YnI+DQomZ3Q7IMKgIDEyMDDCoCDCoCDC
oCDCoCDCoCBpZiAodm1mLSZndDtjb3dfcGFnZSkgezxicj4NCiZndDsgwqAgMTIwMcKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIHNlY3Rvcl90IHNlY3RvciA9IGRheF9pb21hcF9zZWN0b3IoJmFt
cDtpb21hcCwgcG9zKTs8YnI+DQomZ3Q7IMKgIDEyMDLCoCA8YnI+DQomZ3Q7IMKgIDEyMDPCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBzd2l0Y2ggKGlvbWFwLnR5cGUpIHs8YnI+DQomZ3Q7IMKg
IDEyMDTCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBjYXNlIElPTUFQX0hPTEU6PGJyPg0KJmd0
OyDCoCAxMjA1wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgY2FzZSBJT01BUF9VTldSSVRURU46
PGJyPg0KJmd0OyDCoCAxMjA2wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
Y2xlYXJfdXNlcl9oaWdocGFnZSh2bWYtJmd0O2Nvd19wYWdlLCB2YWRkcik7PGJyPg0KJmd0OyDC
oCAxMjA3wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgYnJlYWs7PGJyPg0K
Jmd0OyDCoCAxMjA4wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgY2FzZSBJT01BUF9NQVBQRUQ6
PGJyPg0KJmd0OyDCoCAxMjA5wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
ZXJyb3IgPSBjb3B5X3VzZXJfZGF4KGlvbWFwLmJkZXYsIGlvbWFwLmRheF9kZXYsPGJyPg0KJmd0
OyDCoCAxMjEwwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgc2VjdG9yLCBQQUdFX1NJWkUsIHZtZi0mZ3Q7Y293X3BhZ2UsIHZhZGRy
KTs8YnI+DQomZ3Q7IMKgIDEyMTHCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCBicmVhazs8YnI+DQomZ3Q7IMKgIDEyMTLCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBkZWZh
dWx0Ojxicj4NCiZndDsgwqAgMTIxM8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIFdBUk5fT05fT05DRSgxKTs8YnI+DQomZ3Q7IMKgIDEyMTTCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCBlcnJvciA9IC1FSU87PGJyPg0KJmd0OyDCoCAxMjE1wqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgYnJlYWs7PGJyPg0KJmd0OyDCoCAxMjE2
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfTxicj4NCiZndDsgwqAgMTIxN8KgIDxicj4NCiZn
dDsgwqAgMTIxOMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGlmIChlcnJvcik8YnI+DQomZ3Q7
IMKgIDEyMTnCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBnb3RvIGVycm9y
X2ZpbmlzaF9pb21hcDs8YnI+DQomZ3Q7IMKgIDEyMjDCoCA8YnI+DQomZ3Q7IMKgIDEyMjHCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBfX1NldFBhZ2VVcHRvZGF0ZSh2bWYtJmd0O2Nvd19wYWdl
KTs8YnI+DQomZ3Q7IMKgIDEyMjLCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXQgPSBmaW5p
c2hfZmF1bHQodm1mKTs8YnI+DQomZ3Q7IMKgIDEyMjPCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCBpZiAoIXJldCk8YnI+DQomZ3Q7IMKgIDEyMjTCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCByZXQgPSBWTV9GQVVMVF9ET05FX0NPVzs8YnI+DQomZ3Q7IMKgIDEyMjXCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBnb3RvIGZpbmlzaF9pb21hcDs8YnI+DQomZ3Q7IMKgIDEy
MjbCoCDCoCDCoCDCoCDCoCB9PGJyPg0KJmd0OyDCoCAxMjI3wqAgPGJyPg0KJmd0OyDCoCAxMjI4
wqAgwqAgwqAgwqAgwqAgc3luYyA9IGRheF9mYXVsdF9pc19zeW5jaHJvbm91cyhmbGFncywgdm1h
LCAmYW1wO2lvbWFwKTs8YnI+DQomZ3Q7IMKgIDEyMjnCoCA8YnI+DQomZ3Q7IMKgIDEyMzDCoCDC
oCDCoCDCoCDCoCBzd2l0Y2ggKGlvbWFwLnR5cGUpIHs8YnI+DQomZ3Q7IMKgIDEyMzHCoCDCoCDC
oCDCoCDCoCBjYXNlIElPTUFQX01BUFBFRDo8YnI+DQomZ3Q7IMKgIDEyMzLCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCBpZiAoaW9tYXAuZmxhZ3MgJmFtcDsgSU9NQVBfRl9ORVcpIHs8YnI+DQom
Z3Q7IMKgIDEyMzPCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBjb3VudF92
bV9ldmVudChQR01BSkZBVUxUKTs8YnI+DQomZ3Q7IMKgIDEyMzTCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCBjb3VudF9tZW1jZ19ldmVudF9tbSh2bWEtJmd0O3ZtX21tLCBQ
R01BSkZBVUxUKTs8YnI+DQomZ3Q7IMKgIDEyMzXCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCBtYWpvciA9IFZNX0ZBVUxUX01BSk9SOzxicj4NCiZndDsgwqAgMTIzNsKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIH08YnI+DQomZ3Q7IMKgIDEyMzfCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCBlcnJvciA9IGRheF9pb21hcF9wZm4oJmFtcDtpb21hcCwgcG9zLCBQQUdFX1NJ
WkUsICZhbXA7cGZuKTs8YnI+DQomZ3Q7IMKgIDEyMzjCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCBpZiAoZXJyb3IgJmx0OyAwKTxicj4NCiZndDsgwqAgMTIzOcKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIGdvdG8gZXJyb3JfZmluaXNoX2lvbWFwOzxicj4NCiZndDsgwqAg
MTI0MMKgIDxicj4NCiZndDsgwqAgMTI0McKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGVudHJ5
ID0gZGF4X2luc2VydF9tYXBwaW5nX2VudHJ5KG1hcHBpbmcsIHZtZiwgZW50cnksIHBmbiw8YnI+
DQomZ3Q7IMKgIDEyNDLCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoDAsIHdyaXRlICZhbXA7JmFtcDsgIXN5
bmMpOzxicj4NCiZndDsgwqAgMTI0M8KgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGlmIChJU19F
UlIoZW50cnkpKSB7PGJyPg0KJmd0OyDCoCAxMjQ0wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgwqAgZXJyb3IgPSBQVFJfRVJSKGVudHJ5KTs8YnI+DQomZ3Q7IMKgIDEyNDXCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBnb3RvIGVycm9yX2ZpbmlzaF9pb21h
cDs8YnI+DQomZ3Q7IMKgIDEyNDbCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCB9PGJyPg0KJmd0
OyDCoCAxMjQ3wqAgPGJyPg0KJmd0OyDCoCAxMjQ4wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
Lyo8YnI+DQomZ3Q7IMKgIDEyNDnCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCogSWYgd2Ug
YXJlIGRvaW5nIHN5bmNocm9ub3VzIHBhZ2UgZmF1bHQgYW5kIGlub2RlIG5lZWRzIGZzeW5jLDxi
cj4NCiZndDsgwqAgMTI1MMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgKiB3ZSBjYW4gaW5z
ZXJ0IFBURSBpbnRvIHBhZ2UgdGFibGVzIG9ubHkgYWZ0ZXIgdGhhdCBoYXBwZW5zLjxicj4NCiZn
dDsgwqAgMTI1McKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgKiBTa2lwIGluc2VydGlvbiBm
b3Igbm93IGFuZCByZXR1cm4gdGhlIHBmbiBzbyB0aGF0IGNhbGxlciBjYW48YnI+DQomZ3Q7IMKg
IDEyNTLCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCogaW5zZXJ0IGl0IGFmdGVyIGZzeW5j
IGlzIGRvbmUuPGJyPg0KJmd0OyDCoCAxMjUzwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAq
Lzxicj4NCiZndDsgwqAgMTI1NMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGlmIChzeW5jKSB7
PGJyPg0KJmd0OyDCoCAxMjU1wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
aWYgKFdBUk5fT05fT05DRSghcGZucCkpIHs8YnI+DQomZ3Q7IMKgIDEyNTbCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCBlcnJvciA9IC1FSU87PGJyPg0K
Jmd0OyDCoCAxMjU3wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgZ290byBlcnJvcl9maW5pc2hfaW9tYXA7PGJyPg0KJmd0OyDCoCAxMjU4wqAgwqAgwqAg
wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgfTxicj4NCiZndDsgwqAgMTI1OcKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgICpwZm5wID0gcGZuOzxicj4NCiZndDsgwqAg
MTI2MMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIHJldCA9IFZNX0ZBVUxU
X05FRUREU1lOQyB8IG1ham9yOzxicj4NCiZndDsgwqAgMTI2McKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIGdvdG8gZmluaXNoX2lvbWFwOzxicj4NCiZndDsgwqAgMTI2MsKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIH08YnI+DQomZ3Q7IMKgIDEyNjPCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCB0cmFjZV9kYXhfaW5zZXJ0X21hcHBpbmcoaW5vZGUsIHZtZiwgZW50cnkp
Ozxicj4NCiZndDsgwqAgMTI2NMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGlmICh3cml0ZSk8
YnI+DQomZ3Q7ICZndDsgMTI2NcKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IHJldCA9IHZtZl9pbnNlcnRfbWl4ZWRfbWt3cml0ZSh2bWEsIHZhZGRyLCBwZm4pOzxicj4NCiZn
dDsgwqAgMTI2NsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGVsc2U8YnI+DQomZ3Q7IMKgIDEy
NjfCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXQgPSB2bWZfaW5zZXJ0
X21peGVkKHZtYSwgdmFkZHIsIHBmbik7PGJyPg0KJmd0OyDCoCAxMjY4wqAgPGJyPg0KJmd0OyDC
oCAxMjY5wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgZ290byBmaW5pc2hfaW9tYXA7PGJyPg0K
Jmd0OyDCoCAxMjcwwqAgwqAgwqAgwqAgwqAgY2FzZSBJT01BUF9VTldSSVRURU46PGJyPg0KJmd0
OyDCoCAxMjcxwqAgwqAgwqAgwqAgwqAgY2FzZSBJT01BUF9IT0xFOjxicj4NCiZndDsgwqAgMTI3
MsKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGlmICghd3JpdGUpIHs8YnI+DQomZ3Q7IMKgIDEy
NzPCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCByZXQgPSBkYXhfbG9hZF9o
b2xlKG1hcHBpbmcsIGVudHJ5LCB2bWYpOzxicj4NCiZndDsgwqAgMTI3NMKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGdvdG8gZmluaXNoX2lvbWFwOzxicj4NCiZndDsgwqAg
MTI3NcKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIH08YnI+DQomZ3Q7IMKgIDEyNzbCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCAvKkZBTExUSFJVKi88YnI+DQomZ3Q7IMKgIDEyNzfCoCDCoCDC
oCDCoCDCoCBkZWZhdWx0Ojxicj4NCiZndDsgwqAgMTI3OMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKg
IMKgIFdBUk5fT05fT05DRSgxKTs8YnI+DQomZ3Q7IMKgIDEyNznCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCBlcnJvciA9IC1FSU87PGJyPg0KJmd0OyDCoCAxMjgwwqAgwqAgwqAgwqAgwqAgwqAg
wqAgwqAgwqAgYnJlYWs7PGJyPg0KJmd0OyDCoCAxMjgxwqAgwqAgwqAgwqAgwqAgfTxicj4NCiZn
dDsgwqAgMTI4MsKgIDxicj4NCiZndDsgwqAgMTI4M8KgIMKgZXJyb3JfZmluaXNoX2lvbWFwOjxi
cj4NCiZndDsgwqAgMTI4NMKgIMKgIMKgIMKgIMKgIHJldCA9IGRheF9mYXVsdF9yZXR1cm4oZXJy
b3IpIHwgbWFqb3I7PGJyPg0KJmd0OyDCoCAxMjg1wqAgwqBmaW5pc2hfaW9tYXA6PGJyPg0KJmd0
OyDCoCAxMjg2wqAgwqAgwqAgwqAgwqAgaWYgKG9wcy0mZ3Q7aW9tYXBfZW5kKSB7PGJyPg0KJmd0
OyDCoCAxMjg3wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgaW50IGNvcGllZCA9IFBBR0VfU0la
RTs8YnI+DQomZ3Q7IMKgIDEyODjCoCA8YnI+DQomZ3Q7IMKgIDEyODnCoCDCoCDCoCDCoCDCoCDC
oCDCoCDCoCDCoCBpZiAocmV0ICZhbXA7IFZNX0ZBVUxUX0VSUk9SKTxicj4NCiZndDsgwqAgMTI5
MMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIGNvcGllZCA9IDA7PGJyPg0K
Jmd0OyDCoCAxMjkxwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgLyo8YnI+DQomZ3Q7IMKgIDEy
OTLCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCogVGhlIGZhdWx0IGlzIGRvbmUgYnkgbm93
IGFuZCB0aGVyZSYjMzk7cyBubyB3YXkgYmFjayAob3RoZXI8YnI+DQomZ3Q7IMKgIDEyOTPCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCDCoCDCoCogdGhyZWFkIG1heSBiZSBhbHJlYWR5IGhhcHBpbHkg
dXNpbmcgUFRFIHdlIGhhdmUgaW5zdGFsbGVkKS48YnI+DQomZ3Q7IMKgIDEyOTTCoCDCoCDCoCDC
oCDCoCDCoCDCoCDCoCDCoCDCoCogSnVzdCBpZ25vcmUgZXJyb3IgZnJvbSAtJmd0O2lvbWFwX2Vu
ZCBzaW5jZSB3ZSBjYW5ub3QgZG8gbXVjaDxicj4NCiZndDsgwqAgMTI5NcKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgKiB3aXRoIGl0Ljxicj4NCiZndDsgwqAgMTI5NsKgIMKgIMKgIMKgIMKg
IMKgIMKgIMKgIMKgIMKgKi88YnI+DQomZ3Q7IMKgIDEyOTfCoCDCoCDCoCDCoCDCoCDCoCDCoCDC
oCDCoCBvcHMtJmd0O2lvbWFwX2VuZChpbm9kZSwgcG9zLCBQQUdFX1NJWkUsIGNvcGllZCwgZmxh
Z3MsICZhbXA7aW9tYXApOzxicj4NCiZndDsgwqAgMTI5OMKgIMKgIMKgIMKgIMKgIH08YnI+DQom
Z3Q7IMKgIDEyOTnCoCDCoHVubG9ja19lbnRyeTo8YnI+DQomZ3Q7IMKgIDEzMDDCoCDCoCDCoCDC
oCDCoCBwdXRfbG9ja2VkX21hcHBpbmdfZW50cnkobWFwcGluZywgdm1mLSZndDtwZ29mZik7PGJy
Pg0KJmd0OyDCoCAxMzAxwqAgwqBvdXQ6PGJyPg0KJmd0OyDCoCAxMzAywqAgwqAgwqAgwqAgwqAg
dHJhY2VfZGF4X3B0ZV9mYXVsdF9kb25lKGlub2RlLCB2bWYsIHJldCk7PGJyPg0KJmd0OyDCoCAx
MzAzwqAgwqAgwqAgwqAgwqAgcmV0dXJuIHJldDs8YnI+DQomZ3Q7IMKgIDEzMDTCoCB9PGJyPg0K
Jmd0OyDCoCAxMzA1wqAgPGJyPg0KJmd0Ozxicj4NCiZndDsgLS0tPGJyPg0KJmd0OyAwLURBWSBr
ZXJuZWwgdGVzdCBpbmZyYXN0cnVjdHVyZcKgIMKgIMKgIMKgIMKgIMKgIMKgIMKgIE9wZW4gU291
cmNlIFRlY2hub2xvZ3kgQ2VudGVyPGJyPg0KJmd0OyA8YSBocmVmPSJodHRwczovL2xpc3RzLjAx
Lm9yZy9waXBlcm1haWwva2J1aWxkLWFsbCI+aHR0cHM6Ly9saXN0cy4wMS5vcmcvcGlwZXJtYWls
L2tidWlsZC1hbGw8L2E+wqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqAgwqBJbnRlbCBDb3Jwb3Jh
dGlvbjxicj48L3A+DQo=
--001a113db2fa6962fc056a7e1569--
